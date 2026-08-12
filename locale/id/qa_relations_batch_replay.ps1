$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$localeRoot = $PSScriptRoot
$repoRoot = [IO.Path]::GetFullPath((Join-Path $localeRoot '..\..'))
$controlRoot = [IO.Path]::GetFullPath((Join-Path $repoRoot '..\_control'))
$manifestPath = Join-Path $controlRoot 'OPENLOGIC_CLOSURE_MANIFEST_20260812.csv'
$expectedCommit = '9620cc73f9c8e0ad003c514a5d3748f29611c4c0'
& git -C $repoRoot merge-base --is-ancestor $expectedCommit HEAD
if ($LASTEXITCODE -ne 0) {
    throw "Authority mismatch: frozen source commit $expectedCommit is not an ancestor of HEAD"
}

$sourcePaths = @(
    'content/content.tex',
    'content/sets-functions-relations/sets-functions-relations-complete.tex',
    'content/sets-functions-relations/relations/relations-complete.tex',
    'content/sets-functions-relations/relations/relations-as-sets.tex',
    'content/sets-functions-relations/relations/reflections.tex',
    'content/sets-functions-relations/relations/special-properties.tex',
    'content/sets-functions-relations/relations/equivalence-relations.tex',
    'content/sets-functions-relations/relations/orders.tex',
    'content/sets-functions-relations/relations/graphs.tex',
    'content/sets-functions-relations/relations/trees.tex',
    'content/sets-functions-relations/relations/operations.tex'
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
    if (-not (Test-Path -LiteralPath $targetPath)) {
        throw "Target missing: $targetPath"
    }
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

    # Normalize only the three source-level corrections admitted in the
    # Indonesian edition. These substitutions are deliberately exact so an
    # unrelated source/target divergence still fails the replay.
    $sourceForReplay = $source
    if ($sourceRelative -ceq 'content/sets-functions-relations/relations/relations-as-sets.tex') {
        # The source defines \Id{A}, then uses an undefined I three times.
        $sourceForReplay = $sourceForReplay.Replace('$I$', '$\Id{\Nat}$')
        $sourceForReplay = $sourceForReplay.Replace('$K=L\cup I$', '$K=L\cup \Id{\Nat}$')
        $sourceForReplay = [regex]::Replace(
            $sourceForReplay,
            '\$H=G\s+\\cup\s+I\$',
            { param($match) '$H=G \cup \Id{\Nat}$' }
        )
    }
    if ($sourceRelative -ceq 'content/sets-functions-relations/relations/orders.tex') {
        # R^+ is reserved for transitive closure later in this same chapter;
        # use the fresh local name S for this reflexive closure.
        $sourceForReplay = $sourceForReplay.Replace('R^+', 'S')
    }

    # Indonesian correctly removes the English lexical diaeresis in naive.
    $sourceForCommands = $sourceForReplay
    foreach ($entry in $literalPatterns.GetEnumerator()) {
        $sourceSequence = @(Get-Sequence -Text $sourceForCommands -Pattern $entry.Value)
        $targetSequence = @(Get-Sequence -Text $target -Pattern $entry.Value)
        if ($entry.Key -eq 'commands') {
            $sourceSequence = @($sourceSequence | Where-Object { $_ -cne '"' })
            $targetSequence = @($targetSequence | Where-Object { $_ -cne '"' })
        }
        Assert-Sequence -Name "$sourceRelative/$($entry.Key)" -Expected $sourceSequence -Actual $targetSequence
    }

    $sourceIds = @(Get-Sequence -Text $source -Pattern '(?<value>\\olfileid\{[^{}]+\}\{[^{}]+\}\{[^{}]+\})')
    $expectedIds = @($sourceIds | ForEach-Object { $_ -replace '^\\olfileid', '\olfileid[id]' })
    $targetIds = @(Get-Sequence -Text $target -Pattern '(?<value>\\olfileid\[id\]\{[^{}]+\}\{[^{}]+\}\{[^{}]+\})')
    Assert-Sequence -Name "$sourceRelative/file-ids" -Expected $expectedIds -Actual $targetIds

    $sourceParts = @(Get-Sequence -Text $source -Pattern '\\olpart\{(?<value>[^{}]+)\}\{')
    $targetParts = @(Get-Sequence -Text $target -Pattern '\\olpart\{(?<value>[^{}]+)\}\{')
    Assert-Sequence -Name "$sourceRelative/part-ids" -Expected $sourceParts -Actual $targetParts

    $sourceChapters = @(Get-Sequence -Text $source -Pattern '\\olchapter\{(?<value>[^{}]+\}\{[^{}]+)\}\{')
    $targetChapters = @(Get-Sequence -Text $target -Pattern '\\olchapter\{(?<value>[^{}]+\}\{[^{}]+)\}\{')
    Assert-Sequence -Name "$sourceRelative/chapter-ids" -Expected $sourceChapters -Actual $targetChapters

    $sourceMath = @(Get-MathSkeletons $sourceForReplay)
    if ($sourceRelative -ceq 'content/sets-functions-relations/relations/trees.tex') {
        # Exact source correction: the branch definition quantifies z over
        # the tree carrier A, not the undefined symbol X.
        $sourceMath = @($sourceMath | ForEach-Object { $_ -replace 'X\\setminusB', 'A\setminusB' })
    }
    Assert-Sequence -Name "$sourceRelative/math-skeletons" `
        -Expected $sourceMath -Actual @(Get-MathSkeletons $target)
}

"RELATIONS_BATCH_REPLAY_OK files=$($sourcePaths.Count) checks=$checks upstream=$expectedCommit"
