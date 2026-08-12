$ErrorActionPreference = 'Stop'

$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$sourceDir = Join-Path $repoRoot 'content\sets-functions-relations\sets'
$targetDir = Join-Path $PSScriptRoot 'content\sets-functions-relations\sets'
$files = @(
    'sets.tex',
    'basics.tex',
    'subsets.tex',
    'important-sets.tex',
    'unions-and-intersections.tex',
    'pairs-and-products.tex',
    'russells-paradox.tex'
)

function Get-OrderedMatches {
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string]$Pattern
    )

    return @([regex]::Matches(
        $Text,
        $Pattern,
        [Text.RegularExpressions.RegexOptions]::Singleline
    ) | ForEach-Object { $_.Value })
}

function Assert-SequenceEqual {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Source,
        [Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Target
    )

    if ($Source.Count -ne $Target.Count) {
        throw "$Name count mismatch: source=$($Source.Count), target=$($Target.Count)"
    }

    for ($i = 0; $i -lt $Source.Count; $i++) {
        if ([string]$Source[$i] -cne [string]$Target[$i]) {
            throw "$Name mismatch at index $i`nSOURCE: $($Source[$i])`nTARGET: $($Target[$i])"
        }
    }

    Write-Output "PASS $Name count=$($Source.Count)"
}

function Normalize-MathSkeleton {
    param([Parameter(Mandatory)][string]$Math)

    # Prose inside \text{...} is expected to be translated. Replace each
    # balanced argument with one marker while retaining every surrounding
    # mathematical command, delimiter, operator, identifier, and brace.
    $builder = [Text.StringBuilder]::new()
    $i = 0
    while ($i -lt $Math.Length) {
        if (($i + 6 -le $Math.Length) -and
            ($Math.Substring($i, 6) -ceq '\text{')) {
            [void]$builder.Append('\text{<TEXT>}')
            $i += 6
            $depth = 1
            while (($i -lt $Math.Length) -and ($depth -gt 0)) {
                if (($Math[$i] -eq '\') -and ($i + 1 -lt $Math.Length)) {
                    $i += 2
                    continue
                }
                if ($Math[$i] -eq '{') {
                    $depth++
                }
                elseif ($Math[$i] -eq '}') {
                    $depth--
                }
                $i++
            }
            if ($depth -ne 0) {
                throw 'Unbalanced \text{...} argument in math segment.'
            }
            continue
        }
        [void]$builder.Append($Math[$i])
        $i++
    }

    return ([regex]::Replace($builder.ToString(), '\s+', ''))
}

function Get-MathSkeletons {
    param([Parameter(Mandatory)][string]$Text)

    # The selected unit uses inline math, \[...\], align*, and multline*.
    # Array material is nested inside a captured display and is therefore
    # covered without being counted a second time.
    $pattern = '(?<!\\)\$(.*?)(?<!\\)\$|\\\[(.*?)\\\]|\\begin\{(align\*|multline\*)\}(.*?)\\end\{\3\}'
    return @(Get-OrderedMatches -Text $Text -Pattern $pattern |
        ForEach-Object { Normalize-MathSkeleton -Math $_ })
}

$patterns = [ordered]@{
    commands     = '\\[A-Za-z@]+|\\.'
    environments = '\\(?:begin|end)\{[^{}]+\}'
    tokens       = '!!(?:\^)?(?:a)?\{[^{}]+\}s?'
    labels       = '\\ollabel\{[^{}]+\}'
    references   = '\\(?:olref|Olref)(?:\[[^\]]*\]){0,3}\{[^{}]+\}'
    assets       = '\\olasset(?:\[[^\]]*\])?\{[^{}]+\}'
    imports      = '\\olimport\*?(?:\[[^\]]*\])?\{[^{}]+\}'
}

$passCount = 0
foreach ($file in $files) {
    $sourcePath = Join-Path $sourceDir $file
    $targetPath = Join-Path $targetDir $file
    $source = Get-Content -LiteralPath $sourcePath -Raw -Encoding UTF8
    $target = Get-Content -LiteralPath $targetPath -Raw -Encoding UTF8

    Write-Output "FILE $file"
    foreach ($entry in $patterns.GetEnumerator()) {
        $sourceSequence = @(Get-OrderedMatches -Text $source -Pattern $entry.Value)
        $targetSequence = @(Get-OrderedMatches -Text $target -Pattern $entry.Value)
        if ($entry.Key -eq 'commands') {
            # Lexical accent commands are source-language orthography, not
            # mathematical structure. The English source spells naive with
            # a diaeresis; correct Indonesian spells it naif. Compare every
            # other command exactly and check this correction separately.
            $sourceSequence = @($sourceSequence | Where-Object { $_ -cne '\"' })
            $targetSequence = @($targetSequence | Where-Object { $_ -cne '\"' })
        }
        Assert-SequenceEqual -Name "$file/$($entry.Key)" `
            -Source $sourceSequence -Target $targetSequence
        $passCount++
    }

    $sourceMath = @(Get-MathSkeletons -Text $source)
    $targetMath = @(Get-MathSkeletons -Text $target)
    Assert-SequenceEqual -Name "$file/math-skeletons" `
        -Source $sourceMath -Target $targetMath
    $passCount++

    $sourceIds = @(Get-OrderedMatches -Text $source `
        -Pattern '\\olfileid\{([^{}]+)\}\{([^{}]+)\}\{([^{}]+)\}')
    $targetIds = @(Get-OrderedMatches -Text $target `
        -Pattern '\\olfileid\[id\]\{([^{}]+)\}\{([^{}]+)\}\{([^{}]+)\}')
    $expectedTargetIds = @($sourceIds | ForEach-Object {
        $_ -replace '^\\olfileid', '\olfileid[id]'
    })
    Assert-SequenceEqual -Name "$file/file-ids-with-id-locale" `
        -Source $expectedTargetIds -Target $targetIds
    $passCount++
}

$russellSource = Get-Content -LiteralPath (Join-Path $sourceDir 'russells-paradox.tex') -Raw -Encoding UTF8
$russellTarget = Get-Content -LiteralPath (Join-Path $targetDir 'russells-paradox.tex') -Raw -Encoding UTF8
$sourceDiaeresisCount = ([regex]::Matches($russellSource, 'na\\"ive')).Count
$targetDiaeresisCount = ([regex]::Matches($russellTarget, 'na\\"if')).Count
$targetNaifCount = ([regex]::Matches($russellTarget, '(?<![A-Za-z])naif(?![A-Za-z])')).Count
if ($sourceDiaeresisCount -ne 2 -or $targetDiaeresisCount -ne 0 -or $targetNaifCount -ne 2) {
    throw "Lexical accent correction mismatch: source_naive=$sourceDiaeresisCount target_diaeresis=$targetDiaeresisCount target_naif=$targetNaifCount"
}
Write-Output "LEXICAL_ACCENT_CORRECTION_OK source_naive=$sourceDiaeresisCount target_diaeresis=$targetDiaeresisCount target_naif=$targetNaifCount"

Write-Output "STRUCTURAL_REPLAY_OK files=$($files.Count) checks=$passCount upstream=9620cc73f9c8e0ad003c514a5d3748f29611c4c0"
