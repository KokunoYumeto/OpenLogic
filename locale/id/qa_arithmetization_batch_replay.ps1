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
    'content/sets-functions-relations/arithmetization/arithmetization.tex',
    'content/sets-functions-relations/arithmetization/integers.tex',
    'content/sets-functions-relations/arithmetization/rationals.tex',
    'content/sets-functions-relations/arithmetization/reals.tex',
    'content/sets-functions-relations/arithmetization/cuts.tex',
    'content/sets-functions-relations/arithmetization/reflections.tex',
    'content/sets-functions-relations/arithmetization/checking-details.tex',
    'content/sets-functions-relations/arithmetization/cauchy.tex'
)
$expectedClosureIds = 41..48 | ForEach-Object { 'OLP-{0:d4}' -f $_ }

$manifest = Import-Csv -LiteralPath $manifestPath
$manifestByPath = @{}
foreach ($row in $manifest) { $manifestByPath[$row.source_path] = $row }
$checks = 0
$sourceCorrections = 0
$correctionAssertions = 0

function Get-Sha256 {
    param([Parameter(Mandatory)][string]$Path)
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function Normalize-Newlines {
    param([Parameter(Mandatory)][string]$Text)
    return ($Text -replace "`r`n", "`n" -replace "`r", "`n")
}

function Remove-TexComments {
    param([Parameter(Mandatory)][string]$Text)
    $lines = (Normalize-Newlines $Text) -split "`n", 0, 'SimpleMatch'
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
    $normalized = Replace-ProseArgument -Text $normalized -Command 'emph'
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

function Replace-RequiredOrdinal {
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string]$Old,
        [Parameter(Mandatory)][string]$New,
        [Parameter(Mandatory)][string]$Name
    )
    $position = $Text.IndexOf($Old, [StringComparison]::Ordinal)
    if ($position -lt 0) { throw "Expected source defect not found: $Name" }
    $second = $Text.IndexOf($Old, $position + $Old.Length, [StringComparison]::Ordinal)
    if ($second -ge 0) { throw "Source defect is not path-unique: $Name" }
    $script:sourceCorrections++
    return $Text.Substring(0, $position) + $New + $Text.Substring($position + $Old.Length)
}

function Normalize-AdmittedSourceCorrections {
    param(
        [Parameter(Mandatory)][string]$SourceRelative,
        [Parameter(Mandatory)][string]$Text
    )
    $Text = Normalize-Newlines $Text
    switch ($SourceRelative) {
        'content/sets-functions-relations/arithmetization/rationals.tex' {
            $Text = Replace-RequiredOrdinal -Text $Text `
                -Old '$r - s$ can be written as' `
                -New '$s - r$ can be written as' `
                -Name 'rationals/order-difference-orientation'
        }
        'content/sets-functions-relations/arithmetization/reals.tex' {
            $Text = Replace-RequiredOrdinal -Text $Text `
                -Old 'equally refers to both the positive and the negative roots' `
                -New 'denotes the principal (positive) square root' `
                -Name 'reals/principal-square-root-comment'
            $Text = Replace-RequiredOrdinal -Text $Text `
                -Old ('Indeed, we can' + "`n" + 'choose $m$ and $n$ so that the fraction cannot be reduced any further.') `
                -New ('Indeed, we can choose $m$ and $n$ as a least pair representing the ratio,' + "`n" + 'so that the fraction cannot be reduced any further.') `
                -Name 'reals/minimal-pair-premise'
        }
        'content/sets-functions-relations/arithmetization/cuts.tex' {
            $Text = Replace-RequiredOrdinal -Text $Text `
                -Old 'Since $S$ has an upper bound, at least one cut is in $S$' `
                -New 'Since $S$ is non-empty, at least one cut is in $S$' `
                -Name 'cuts/nonempty-union-premise'
            $Text = Replace-RequiredOrdinal -Text $Text `
                -Old '0^\mathbb{R}' `
                -New '0_\Real' `
                -Name 'cuts/real-zero-notation'
        }
        'content/sets-functions-relations/arithmetization/cauchy.tex' {
            $Text = Replace-RequiredOrdinal -Text $Text `
                -Old 'the $n$th decimal place that we are interested in' `
                -New 'the digit in the $n$th decimal place that we are interested in' `
                -Name 'cauchy/nth-decimal-digit'
            $Text = Replace-RequiredOrdinal -Text $Text `
                -Old ('we will (ultimately) want to say that they have the same' + "`n" + 'limit, in the sense employed in \olref{def:CauchySequence},') `
                -New ('their difference tends to zero by a criterion related to' + "`n" + '\olref{def:CauchySequence},') `
                -Name 'cauchy/noncircular-zero-difference'
            $Text = Replace-RequiredOrdinal -Text $Text `
                -Old ('identify real numbers with equivalence' + "`n" + 'relations.') `
                -New ('identify real numbers with equivalence' + "`n" + 'classes.') `
                -Name 'cauchy/equivalence-classes-not-relations'
            $Text = Replace-RequiredOrdinal -Text $Text `
                -Old '0_\Rat' `
                -New '0_\Real' `
                -Name 'cauchy/real-zero-notation'
            $Text = Replace-RequiredOrdinal -Text $Text `
                -Old '$q_{\Real} < r$' `
                -New '$q_{\Real} < \equivrep{r}{}$' `
                -Name 'cauchy/compare-embedded-class'
            $Text = Replace-RequiredOrdinal -Text $Text `
                -Old ('the difference between $f$ and $g$ halves at each' + "`n" + 'step.') `
                -New ('the difference between $f$ and $g$ is at most halved at each' + "`n" + 'step.') `
                -Name 'cauchy/gap-at-most-halved'
        }
    }
    return $Text
}

function Assert-TargetCorrection {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Required,
        [AllowEmptyString()][string]$Rejected = ''
    )
    $text = Normalize-Newlines ([IO.File]::ReadAllText($Path))
    if ($text.IndexOf($Required, [StringComparison]::Ordinal) -lt 0) {
        throw "Required corrected target form missing: $Name"
    }
    if ($Rejected.Length -gt 0 -and
        $text.IndexOf($Rejected, [StringComparison]::Ordinal) -ge 0) {
        throw "Rejected source-defective target form remains: $Name"
    }
    $script:correctionAssertions++
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

    $sourceRaw = [IO.File]::ReadAllText($sourcePath)
    $sourceRaw = Normalize-AdmittedSourceCorrections -SourceRelative $sourceRelative -Text $sourceRaw
    $source = Remove-TexComments $sourceRaw
    $target = Remove-TexComments ([IO.File]::ReadAllText($targetPath))
    if ((Get-BraceBalance $source) -ne 0 -or (Get-BraceBalance $target) -ne 0) {
        throw "Brace balance failed for $sourceRelative"
    }
    $checks++

    foreach ($entry in $literalPatterns.GetEnumerator()) {
        $expectedSequence = @(Get-Sequence -Text $source -Pattern $entry.Value)
        $actualSequence = @(Get-Sequence -Text $target -Pattern $entry.Value)
        if ($entry.Key -eq 'commands') {
            # English uses a TeX diaeresis in na\"ive; Indonesian correctly
            # spells naif without a lexical accent command.
            $expectedSequence = @($expectedSequence | Where-Object { $_ -cne '"' })
            $actualSequence = @($actualSequence | Where-Object { $_ -cne '"' })
        }
        Assert-Sequence -Name "$sourceRelative/$($entry.Key)" `
            -Expected $expectedSequence -Actual $actualSequence
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

$arithRoot = Join-Path $localeRoot 'content\sets-functions-relations\arithmetization'
$rationalsPath = Join-Path $arithRoot 'rationals.tex'
$realsPath = Join-Path $arithRoot 'reals.tex'
$cutsPath = Join-Path $arithRoot 'cuts.tex'
$cauchyPath = Join-Path $arithRoot 'cauchy.tex'

Assert-TargetCorrection -Name 'rationals/order-difference-orientation' -Path $rationalsPath `
    -Required '$r \le s$ jika dan hanya jika $s - r$ tidak negatif, yaitu $s - r$ dapat ditulis sebagai' `
    -Rejected 'yaitu $r - s$ dapat ditulis sebagai'
Assert-TargetCorrection -Name 'cuts/nonempty-union-premise' -Path $cutsPath `
    -Required 'Karena $S$ takkosong, sekurang-kurangnya satu potongan' `
    -Rejected 'Karena $S$ mempunyai suatu batas atas, sekurang-kurangnya satu potongan'
Assert-TargetCorrection -Name 'cuts/real-zero-notation' -Path $cutsPath `
    -Required '\cup 0_\Real & \text{jika }\alpha, \beta \geq 0_\Real' `
    -Rejected '\cup 0^\mathbb{R}'
Assert-TargetCorrection -Name 'reals/principal-square-root-comment' -Path $realsPath `
    -Required 'merujuk pada akar kuadrat utama, yakni akar positif' `
    -Rejected 'sama-sama merujuk pada akar positif maupun akar negatif'
Assert-TargetCorrection -Name 'reals/minimal-pair-premise' -Path $realsPath `
    -Required ('$n$. Kita bahkan dapat memilih $m$ dan $n$ sebagai pasangan terkecil yang' + "`n" + 'mewakili rasio tersebut') `
    -Rejected '$n$. Kita bahkan dapat memilih $m$ dan $n$ sehingga pecahannya'
Assert-TargetCorrection -Name 'reals/rigorous-register' -Path $realsPath `
    -Required 'sepenuhnya ketat secara matematis' `
    -Rejected 'sepenuhnya ketat, dan'
Assert-TargetCorrection -Name 'cauchy/nth-decimal-digit' -Path $cauchyPath `
    -Required 'menyatakan digit pada tempat desimal ke-$n$' `
    -Rejected '$d(n)$ sebagai tempat desimal'
Assert-TargetCorrection -Name 'cauchy/noncircular-zero-difference' -Path $cauchyPath `
    -Required 'setelah suku pertama, selisih keduanya mendekati nol menurut kriteria yang' `
    -Rejected 'keduanya mempunyai limit yang sama'
Assert-TargetCorrection -Name 'cauchy/equivalence-classes-not-relations' -Path $cauchyPath `
    -Required ('mengidentifikasi bilangan real dengan' + "`n" + 'kelas-kelas ekuivalensi') `
    -Rejected ('mengidentifikasi bilangan real dengan relasi' + "`n" + 'ekuivalensi')
Assert-TargetCorrection -Name 'cauchy/real-zero-notation' -Path $cauchyPath `
    -Required '\equivrep{f}{}\neq 0_\Real' `
    -Rejected '\equivrep{f}{}\neq 0_\Rat'
Assert-TargetCorrection -Name 'cauchy/compare-embedded-class' -Path $cauchyPath `
    -Required '$q_{\Real} < \equivrep{r}{}$' `
    -Rejected '$q_{\Real} < r$'
Assert-TargetCorrection -Name 'cauchy/gap-at-most-halved' -Path $cauchyPath `
    -Required 'selisih antara $f$ dan $g$ menjadi paling banyak setengah' `
    -Rejected 'selisih antara $f$ dan $g$ menjadi setengah pada'

if ($sourceCorrections -ne 11) {
    throw "Source-correction count mismatch: expected=11 actual=$sourceCorrections"
}
if ($correctionAssertions -ne 12) {
    throw "Target-correction assertion count mismatch: expected=12 actual=$correctionAssertions"
}

"ARITHMETIZATION_BATCH_REPLAY_OK files=$($sourcePaths.Count) checks=$checks source_corrections=$sourceCorrections target_corrections=$correctionAssertions upstream=$expectedCommit closure=OLP-0041..OLP-0048"
