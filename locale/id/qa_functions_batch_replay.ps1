$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$localeRoot = $PSScriptRoot
$repoRoot = [IO.Path]::GetFullPath((Join-Path $localeRoot '..\..'))
$controlRoot = [IO.Path]::GetFullPath((Join-Path $repoRoot '..\_control'))
$manifestPath = Join-Path $controlRoot 'OPENLOGIC_CLOSURE_MANIFEST_20260812.csv'
$expectedCommit = '9620cc73f9c8e0ad003c514a5d3748f29611c4c0'
$actualCommit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or $actualCommit -cne $expectedCommit) {
    throw "Authority mismatch: expected $expectedCommit, got $actualCommit"
}

$sourcePaths = @(
    'content/sets-functions-relations/functions/functions.tex',
    'content/sets-functions-relations/functions/function-basics.tex',
    'content/sets-functions-relations/functions/function-kinds.tex',
    'content/sets-functions-relations/functions/functions-relations.tex',
    'content/sets-functions-relations/functions/inverses.tex',
    'content/sets-functions-relations/functions/composition.tex',
    'content/sets-functions-relations/functions/partial-functions.tex'
)

$manifest = Import-Csv -LiteralPath $manifestPath
$manifestByPath = @{}
foreach ($row in $manifest) { $manifestByPath[$row.source_path] = $row }
$checks = 0

function Get-Sha256 {
    param([Parameter(Mandatory)][string]$Path)
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function Get-Sequence {
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string]$Pattern,
        [string]$Group = 'value'
    )
    return @([regex]::Matches(
        $Text,
        $Pattern,
        [Text.RegularExpressions.RegexOptions]::Singleline
    ) | ForEach-Object { $_.Groups[$Group].Value })
}

function Assert-Sequence {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Expected,
        [Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Actual
    )
    if ($Expected.Count -ne $Actual.Count) {
        throw "$Name count mismatch: source=$($Expected.Count), target=$($Actual.Count)"
    }
    for ($index = 0; $index -lt $Expected.Count; $index++) {
        if ([string]$Expected[$index] -cne [string]$Actual[$index]) {
            throw "$Name mismatch at index $index`nSOURCE: $($Expected[$index])`nTARGET: $($Actual[$index])"
        }
    }
    $script:checks++
    "PASS $Name count=$($Expected.Count)"
}

function Get-BraceBalance {
    param([Parameter(Mandatory)][string]$Text)
    $balance = 0
    for ($index = 0; $index -lt $Text.Length; $index++) {
        if ($Text[$index] -eq '%' -and ($index -eq 0 -or $Text[$index - 1] -ne '\')) {
            while ($index -lt $Text.Length -and $Text[$index] -ne "`n") { $index++ }
            continue
        }
        if ($Text[$index] -eq '{' -and ($index -eq 0 -or $Text[$index - 1] -ne '\')) { $balance++ }
        if ($Text[$index] -eq '}' -and ($index -eq 0 -or $Text[$index - 1] -ne '\')) { $balance-- }
        if ($balance -lt 0) { return $balance }
    }
    return $balance
}

function Replace-ProseArgument {
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string]$Command
    )
    $needle = "\$Command{"
    $builder = [Text.StringBuilder]::new()
    $index = 0
    while ($index -lt $Text.Length) {
        if (($index + $needle.Length -le $Text.Length) -and
            ($Text.Substring($index, $needle.Length) -ceq $needle)) {
            [void]$builder.Append("\$Command{<TEXT>}")
            $index += $needle.Length
            $depth = 1
            while ($index -lt $Text.Length -and $depth -gt 0) {
                if ($Text[$index] -eq '\' -and $index + 1 -lt $Text.Length) {
                    $index += 2
                    continue
                }
                if ($Text[$index] -eq '{') { $depth++ }
                elseif ($Text[$index] -eq '}') { $depth-- }
                $index++
            }
            if ($depth -ne 0) { throw "Unbalanced \$Command argument" }
            continue
        }
        [void]$builder.Append($Text[$index])
        $index++
    }
    return $builder.ToString()
}

function Normalize-Math {
    param([Parameter(Mandatory)][string]$Text)
    $normalized = Replace-ProseArgument -Text $Text -Command 'text'
    $normalized = Replace-ProseArgument -Text $normalized -Command 'intertext'
    return [regex]::Replace($normalized, '\s+', '')
}

function Get-MathSkeletons {
    param([Parameter(Mandatory)][string]$Text)
    $segments = [Collections.Generic.List[string]]::new()
    foreach ($match in [regex]::Matches($Text, '(?<!\\)\$(.*?)(?<!\\)\$', 'Singleline')) {
        $segments.Add('INLINE:' + (Normalize-Math $match.Value))
    }
    foreach ($match in [regex]::Matches($Text, '\\\[(.*?)\\\]', 'Singleline')) {
        $segments.Add('DISPLAY:' + (Normalize-Math $match.Value))
    }
    foreach ($match in [regex]::Matches($Text, '\\begin\{(align\*|multline\*)\}(.*?)\\end\{\1\}', 'Singleline')) {
        $segments.Add('ENV:' + (Normalize-Math $match.Value))
    }
    return @($segments)
}

$literalPatterns = [ordered]@{
    commands = '\\(?<value>[A-Za-z@]+|.)'
    environments = '\\(?:begin|end)\{(?<value>[^{}]+)\}'
    localization_tokens = '(?<value>!!(?:\^)?(?:a)?\{[^{}]+\}s?)'
    labels = '(?<value>\\ollabel\{[^{}]+\})'
    references = '(?<value>\\(?:olref|Olref)(?:\[[^\]]*\]){0,3}\{[^{}]+\})'
    assets = '(?<value>\\olasset(?:\[[^\]]*\])?\{[^{}]+\})'
    imports = '(?<value>\\olimport\*?(?:\[[^\]]*\])?\{[^{}]+\})'
    href_urls = '\\href\{(?<value>[^{}]+)\}\{'
    citations = '(?<value>\\cite[a-zA-Z]*\{[^{}]+\})'
    documentclass = '(?<value>\\documentclass\[[^\]]+\]\{subfiles\})'
}

foreach ($sourceRelative in $sourcePaths) {
    if (-not $manifestByPath.ContainsKey($sourceRelative)) {
        throw "Source missing from closure manifest: $sourceRelative"
    }
    $sourcePath = Join-Path $repoRoot ($sourceRelative -replace '/', '\')
    $targetPath = Join-Path $localeRoot ($sourceRelative -replace '^content/', 'content/' -replace '/', '\')
    if (-not (Test-Path -LiteralPath $targetPath)) { throw "Target missing: $targetPath" }

    $sourceHash = Get-Sha256 $sourcePath
    $manifestHash = $manifestByPath[$sourceRelative].source_sha256.ToLowerInvariant()
    if ($sourceHash -cne $manifestHash) {
        throw "Source hash mismatch for ${sourceRelative}: manifest=$manifestHash disk=$sourceHash"
    }
    $checks++
    "PASS $sourceRelative/source-hash $sourceHash"

    $source = [IO.File]::ReadAllText($sourcePath)
    $target = [IO.File]::ReadAllText($targetPath)
    if ((Get-BraceBalance $source) -ne 0 -or (Get-BraceBalance $target) -ne 0) {
        throw "Brace balance failed for $sourceRelative"
    }
    $checks++
    "PASS $sourceRelative/brace-balance"

    foreach ($entry in $literalPatterns.GetEnumerator()) {
        Assert-Sequence -Name "$sourceRelative/$($entry.Key)" `
            -Expected @(Get-Sequence -Text $source -Pattern $entry.Value) `
            -Actual @(Get-Sequence -Text $target -Pattern $entry.Value)
    }

    $sourceIds = @(Get-Sequence -Text $source -Pattern '(?<value>\\olfileid\{[^{}]+\}\{[^{}]+\}\{[^{}]+\})')
    $expectedIds = @($sourceIds | ForEach-Object { $_ -replace '^\\olfileid', '\olfileid[id]' })
    $targetIds = @(Get-Sequence -Text $target -Pattern '(?<value>\\olfileid\[id\]\{[^{}]+\}\{[^{}]+\}\{[^{}]+\})')
    Assert-Sequence -Name "$sourceRelative/file-ids" -Expected $expectedIds -Actual $targetIds

    $sourceChapters = @(Get-Sequence -Text $source -Pattern '\\olchapter\{(?<value>[^{}]+\}\{[^{}]+)\}\{')
    $targetChapters = @(Get-Sequence -Text $target -Pattern '\\olchapter\{(?<value>[^{}]+\}\{[^{}]+)\}\{')
    Assert-Sequence -Name "$sourceRelative/chapter-ids" -Expected $sourceChapters -Actual $targetChapters

    Assert-Sequence -Name "$sourceRelative/math-skeletons" `
        -Expected @(Get-MathSkeletons $source) -Actual @(Get-MathSkeletons $target)
}

"FUNCTIONS_BATCH_REPLAY_OK files=$($sourcePaths.Count) checks=$checks upstream=$expectedCommit"
