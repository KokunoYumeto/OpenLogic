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
    'content/sets-functions-relations/size-of-sets/size-of-sets-complete.tex',
    'content/sets-functions-relations/size-of-sets/introduction.tex',
    'content/sets-functions-relations/size-of-sets/enumerability.tex',
    'content/sets-functions-relations/size-of-sets/zig-zag.tex',
    'content/sets-functions-relations/size-of-sets/pairing.tex',
    'content/sets-functions-relations/size-of-sets/pairing-alt.tex',
    'content/sets-functions-relations/size-of-sets/non-enumerability.tex',
    'content/sets-functions-relations/size-of-sets/reduction.tex',
    'content/sets-functions-relations/size-of-sets/equinumerous-sets.tex',
    'content/sets-functions-relations/size-of-sets/comparing-size.tex',
    'content/sets-functions-relations/size-of-sets/schroder-bernstein.tex',
    'content/sets-functions-relations/size-of-sets/enumerability-alt.tex',
    'content/sets-functions-relations/size-of-sets/non-enumerability-alt.tex',
    'content/sets-functions-relations/size-of-sets/reduction-alt.tex'
)
$expectedClosureIds = 27..40 | ForEach-Object { 'OLP-{0:d4}' -f $_ }

$manifest = Import-Csv -LiteralPath $manifestPath
$manifestByPath = @{}
foreach ($row in $manifest) { $manifestByPath[$row.source_path] = $row }
$checks = 0

function Get-Sha256 {
    param([Parameter(Mandatory)][string]$Path)
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function Remove-TexComments {
    param([Parameter(Mandatory)][string]$Text)
    $lines = $Text -split "`r?`n", 0, 'RegexMatch'
    return (($lines | ForEach-Object {
        $line = $_
        $cut = -1
        for ($index = 0; $index -lt $line.Length; $index++) {
            if ($line[$index] -ne '%') { continue }
            $slashes = 0
            for ($left = $index - 1; $left -ge 0 -and $line[$left] -eq '\'; $left--) { $slashes++ }
            if (($slashes % 2) -eq 0) { $cut = $index; break }
        }
        if ($cut -ge 0) { $line.Substring(0, $cut) } else { $line }
    }) -join "`n")
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
}

function Get-BraceBalance {
    param([Parameter(Mandatory)][string]$Text)
    $balance = 0
    for ($index = 0; $index -lt $Text.Length; $index++) {
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
    foreach ($match in [regex]::Matches($Text, '\\begin\{(align\*?|multline\*?|equation\*?)\}(.*?)\\end\{\1\}', 'Singleline')) {
        $segments.Add('ENV:' + (Normalize-Math $match.Value))
    }
    return @($segments)
}

function Normalize-AdmittedSourceCorrections {
    param(
        [Parameter(Mandatory)][string]$SourceRelative,
        [Parameter(Mandatory)][string]$Text
    )
    switch ($SourceRelative) {
        'content/sets-functions-relations/size-of-sets/pairing.tex' {
            # k(k+1)/2 sums the positive integers through k, not those < k.
            $Text = $Text.Replace('$< k$', '$k$')
            # A pairing function is only injective. Its inverse is partial on
            # its range; that partial inverse nevertheless orders every pair.
            $Text = $Text.Replace(
                'Show that the inverse of $f$ is an enumeration of $A \times B$.',
                'Show that the partial inverse of $f$ on its range determines an enumeration of $A \times B$.'
            )
        }
        'content/sets-functions-relations/size-of-sets/pairing-alt.tex' {
            # The prose examples must match the displayed enumeration.
            $Text = $Text.Replace('$\tuple{0,2}$', '$\tuple{0,1}$')
            $Text = $Text.Replace('$\tuple{2,m}$, $\tuple{2,m}$', '$\tuple{2,m}$, $\tuple{3,m}$')
        }
        'content/sets-functions-relations/size-of-sets/non-enumerability.tex' {
            # The comparison is with the alternative non-enumerability section.
            $Text = $Text.Replace('\olref[enm-alt]{sec}', '\olref[nen-alt]{sec}')
        }
        'content/sets-functions-relations/size-of-sets/reduction.tex' {
            # The constructed sequence is named s; k is undefined here.
            $Text = $Text.Replace('$s_{k}$', '$s$')
            $Text = $Text.Replace('$s_{k}(n) = 1$', '$s(n) = 1$')
            $Text = $Text.Replace('$s_{k}(n) = 0$', '$s(n) = 0$')
            $Text = $Text.Replace('$s_k(n) = 1$', '$s(n) = 1$')
            $Text = $Text.Replace('$s_k(n) = 0$', '$s(n) = 0$')
        }
        'content/sets-functions-relations/size-of-sets/reduction-alt.tex' {
            $Text = $Text.Replace('$s_{k}$', '$s$')
            $Text = $Text.Replace('$s_{k}(n) = 1$', '$s(n) = 1$')
            $Text = $Text.Replace('$s_{k}(n) = 0$', '$s(n) = 0$')
            $Text = $Text.Replace('$s_k(n) = 1$', '$s(n) = 1$')
            $Text = $Text.Replace('$s_k(n) = 0$', '$s(n) = 0$')
            # Standard and alternative reduction sections are both imported;
            # upstream assigns the same global label to distinct problems.
            $Text = $Text.Replace('\label{sfr:siz:red:prob:nat-nat}', '\label{sfr:siz:red-alt:prob:nat-nat}')
        }
        'content/sets-functions-relations/size-of-sets/equinumerous-sets.tex' {
            # y is in the range of f, not g.
            $Text = $Text.Replace('$g(x) = y$', '$f(x) = y$')
        }
        'content/sets-functions-relations/size-of-sets/comparing-size.tex' {
            # x was chosen arbitrarily from A, not from the diagonal subset.
            $old = 'for each $x \in' + "`n" + '  \overline{A}$'
            $position = $Text.IndexOf($old, [StringComparison]::Ordinal)
            if ($position -lt 0) { throw 'Expected comparing-size source defect not found' }
            $replacement = 'for each $x \in' + "`n" + '  A$'
            $Text = $Text.Substring(0, $position) + $replacement + $Text.Substring($position + $old.Length)
        }
        'content/sets-functions-relations/size-of-sets/non-enumerability-alt.tex' {
            # Repair two transposed prose indices and the duplicated bit flip.
            $Text = $Text.Replace('$s_n(m)$ in row~$m$ and column~$n$', '$s_n(m)$ in row~$n$ and column~$m$')
            $Text = $Text.Replace('changing each $1$ to a $0$, and each $1$ to a $0$', 'changing each $1$ to a $0$, and each $0$ to a $1$')
            $Text = $Text.Replace('changing every $1$ to a $0$ and' + "`n" + 'every $1$ to a~$0$', 'changing every $1$ to a $0$ and' + "`n" + 'every $0$ to a~$1$')
        }
    }
    return $Text
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

for ($fileIndex = 0; $fileIndex -lt $sourcePaths.Count; $fileIndex++) {
    $sourceRelative = $sourcePaths[$fileIndex]
    if (-not $manifestByPath.ContainsKey($sourceRelative)) {
        throw "Source missing from closure manifest: $sourceRelative"
    }
    $row = $manifestByPath[$sourceRelative]
    if ($row.closure_id -cne $expectedClosureIds[$fileIndex]) {
        throw "Closure order mismatch for ${sourceRelative}: expected=$($expectedClosureIds[$fileIndex]) actual=$($row.closure_id)"
    }
    $sourcePath = Join-Path $repoRoot ($sourceRelative -replace '/', '\')
    $targetPath = Join-Path $localeRoot ($sourceRelative -replace '^content/', 'content/' -replace '/', '\')
    if (-not (Test-Path -LiteralPath $targetPath)) { throw "Target missing: $targetPath" }

    $sourceHash = Get-Sha256 $sourcePath
    $manifestHash = $row.source_sha256.ToLowerInvariant()
    if ($sourceHash -cne $manifestHash) {
        throw "Source hash mismatch for ${sourceRelative}: manifest=$manifestHash disk=$sourceHash"
    }
    $checks++

    $source = Remove-TexComments ([IO.File]::ReadAllText($sourcePath))
    $source = Normalize-AdmittedSourceCorrections -SourceRelative $sourceRelative -Text $source
    $target = Remove-TexComments ([IO.File]::ReadAllText($targetPath))
    if ((Get-BraceBalance $source) -ne 0 -or (Get-BraceBalance $target) -ne 0) {
        throw "Brace balance failed for $sourceRelative"
    }
    $checks++

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

"SIZE_OF_SETS_BATCH_REPLAY_OK files=$($sourcePaths.Count) checks=$checks upstream=$expectedCommit closure=OLP-0027..OLP-0040"
