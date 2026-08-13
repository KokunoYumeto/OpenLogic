$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$localeRoot = $PSScriptRoot
$repoRoot = [IO.Path]::GetFullPath((Join-Path $localeRoot '..\..'))
$controlRoot = [IO.Path]::GetFullPath((Join-Path $repoRoot '..\_control'))
$manifestPath = Join-Path $controlRoot 'OPENLOGIC_CLOSURE_MANIFEST_20260812.csv'
$expectedCommit = '9620cc73f9c8e0ad003c514a5d3748f29611c4c0'

$null = & git -C $repoRoot merge-base --is-ancestor $expectedCommit HEAD
if ($LASTEXITCODE -ne 0) {
    throw "Authority mismatch: frozen source commit $expectedCommit is not an ancestor of HEAD"
}

$files = @(
    [pscustomobject]@{
        ClosureId = 'OLP-0049'
        Source = 'content/sets-functions-relations/infinite/infinite.tex'
        SourceSha256 = '1f4a788f692454adc1a93e2670899f785f45ee9849952ac2f36fce7cdd77dbff'
        TargetSha256 = '5c3dfc0856dab17c0617a6b3fc188442dbb67726764192f130bd7873f78e10a4'
    }
    [pscustomobject]@{
        ClosureId = 'OLP-0050'
        Source = 'content/sets-functions-relations/infinite/hilberts-hotel.tex'
        SourceSha256 = 'e9a73caefcc496d7074251a3ac15f66fd577415bd3a531dd23f79375502ee0ed'
        TargetSha256 = 'a81da0629916dc0b920f7a77d2cd9ac5f8274af6439a82f36d640127bc55879e'
    }
    [pscustomobject]@{
        ClosureId = 'OLP-0051'
        Source = 'content/sets-functions-relations/infinite/dedekind-algebra.tex'
        SourceSha256 = '9cee716bb8cb3bfd507ed5c17bbd4477d05995af6f8f8d411087793bdaa86036'
        TargetSha256 = '1d68378a390b4de543c8a8f83fe91f73ef58c1c66d1953fb0daa0b972a911da7'
    }
    [pscustomobject]@{
        ClosureId = 'OLP-0052'
        Source = 'content/sets-functions-relations/infinite/dedekind-induction.tex'
        SourceSha256 = 'ea5f6c80d70abca6f5598de3e221c2f60524c40cbf533ae8a5336d5bb7186537'
        TargetSha256 = 'bb2dce323e32a4b1831b00b885118409f0f89b1a8e45f11b6da85ca3261015e6'
    }
    [pscustomobject]@{
        ClosureId = 'OLP-0053'
        Source = 'content/sets-functions-relations/infinite/dedekinds-proof.tex'
        SourceSha256 = 'a7c41cebb6b7b0e2bed0d187777be4ba69fecdb17baa070975a0ca5c5c55b8bf'
        TargetSha256 = '91d6b5d2ea4bd572dc30ff6100c57e8918977c800f59a50e04212e801b7a2dcd'
    }
    [pscustomobject]@{
        ClosureId = 'OLP-0054'
        Source = 'content/sets-functions-relations/infinite/card-sb.tex'
        SourceSha256 = '88534a3f2be736a704ab31343e45933edb9712fa5b4411eb102c0f4a12d656e9'
        TargetSha256 = '001e757715635c0746fa93a84b5677f5db2a47e6f608391be1b3c719b2097b7f'
    }
)

$manifest = Import-Csv -LiteralPath $manifestPath
$manifestByPath = @{}
foreach ($row in $manifest) { $manifestByPath[$row.source_path] = $row }

$checks = 1
$sourceCorrections = 0
$readerTextExceptions = 0
$targetCorrectionAssertions = 0
$adverseAssertions = 0

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

function Assert-ContainsOrdinal {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string]$Required,
        [AllowEmptyString()][string]$Rejected = '',
        [ValidateSet('target-correction', 'adverse')][string]$Kind = 'target-correction'
    )
    if ($Text.IndexOf($Required, [StringComparison]::Ordinal) -lt 0) {
        throw "Required form missing: $Name"
    }
    if ($Rejected.Length -gt 0 -and
        $Text.IndexOf($Rejected, [StringComparison]::Ordinal) -ge 0) {
        throw "Rejected form remains: $Name"
    }
    if ($Kind -eq 'adverse') { $script:adverseAssertions++ }
    else { $script:targetCorrectionAssertions++ }
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
    $normalized = $Text
    foreach ($command in @('text', 'intertext', 'mbox', 'textrm', 'textnormal')) {
        $normalized = Replace-ProseArgument -Text $normalized -Command $command
    }
    return [regex]::Replace($normalized, '\s+', '')
}

function Get-MathSkeletons {
    param([Parameter(Mandatory)][string]$Text)
    $normalizedText = $Text
    foreach ($command in @('text', 'intertext', 'mbox', 'textrm', 'textnormal')) {
        $normalizedText = Replace-ProseArgument -Text $normalizedText -Command $command
    }
    $pattern = '(?<display>\$\$.*?\$\$|\\\[.*?\\\]|\\begin\{(?<env>align\*?|multline\*?|equation\*?)\}.*?\\end\{\k<env>\})|(?<inline>(?<!\\)\$(?!\$).*?(?<!\\)\$(?!\$))'
    return @([regex]::Matches(
        $normalizedText,
        $pattern,
        [Text.RegularExpressions.RegexOptions]::Singleline
    ) | ForEach-Object {
        if ($_.Groups['display'].Success) { 'DISPLAY:' + (Normalize-Math $_.Value) }
        else { 'INLINE:' + (Normalize-Math $_.Value) }
    })
}

function Replace-RequiredOrdinal {
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string]$Old,
        [Parameter(Mandatory)][string]$New,
        [Parameter(Mandatory)][string]$Name
    )
    $position = $Text.IndexOf($Old, [StringComparison]::Ordinal)
    if ($position -lt 0) { throw "Expected frozen-source defect not found: $Name" }
    $second = $Text.IndexOf($Old, $position + $Old.Length, [StringComparison]::Ordinal)
    if ($second -ge 0) { throw "Frozen-source defect is not path-unique: $Name" }
    $script:sourceCorrections++
    return $Text.Substring(0, $position) + $New + $Text.Substring($position + $Old.Length)
}

function Replace-ReaderOrderingOrdinal {
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string]$Old,
        [Parameter(Mandatory)][string]$New,
        [Parameter(Mandatory)][string]$Name
    )
    $position = $Text.IndexOf($Old, [StringComparison]::Ordinal)
    if ($position -lt 0) { throw "Expected reader-order source form not found: $Name" }
    $second = $Text.IndexOf($Old, $position + $Old.Length, [StringComparison]::Ordinal)
    if ($second -ge 0) { throw "Reader-order source form is not path-unique: $Name" }
    $script:readerTextExceptions++
    return $Text.Substring(0, $position) + $New + $Text.Substring($position + $Old.Length)
}

function Normalize-AdmittedSourceCorrections {
    param(
        [Parameter(Mandatory)][string]$SourceRelative,
        [Parameter(Mandatory)][string]$Text
    )
    $Text = Normalize-Newlines $Text
    if ($SourceRelative -cne 'content/sets-functions-relations/infinite/card-sb.tex') {
        return $Text
    }

    $Text = Replace-RequiredOrdinal -Text $Text `
        -Old 'If $A \subseteq B \subseteq C$ and $A \approx C$, then $\cardeq{\cardeq{A}{B}}{C}$.' `
        -New 'If $A \subseteq B \subseteq C$ and $A \approx C$, then $\cardeq{B}{C}$.' `
        -Name 'card-sb/sbhelper-consequent'

    $oldRangeStep = 'It remains to show that $\ran{g} = B$. So fix $x \in B \subseteq C$.'
    $newRangeStep = 'It remains to show that $\ran{g} = B$. First, ' +
        '$\ran{g} \subseteq B$: if $x \in F$, then $g(x)=f(x) \in A \subseteq B$; ' +
        'if $x \notin F$, then $x \in B$ because $C\setminus B \subseteq F$, and hence ' +
        '$g(x)=x \in B$. For the converse inclusion, fix $x \in B \subseteq C$.'
    $Text = Replace-RequiredOrdinal -Text $Text `
        -Old $oldRangeStep -New $newRangeStep `
        -Name 'card-sb/range-subset-inclusion'

    return $Text
}

function Normalize-TranslatedReaderOrdering {
    param(
        [Parameter(Mandatory)][string]$SourceRelative,
        [Parameter(Mandatory)][string]$Text
    )
    if ($SourceRelative -cne 'content/sets-functions-relations/infinite/dedekind-algebra.tex') {
        return $Text
    }
    return Replace-ReaderOrderingOrdinal -Text $Text `
        -Old ('and now $f(x) \in X$ as $X$ is' + "`n" + '$f$-closed.') `
        -New 'and as $X$ is $f$-closed, now $f(x) \in X$.' `
        -Name 'dedekind-algebra/closureclosed-reader-order'
}

$literalPatterns = [ordered]@{
    commands = '\\(?<value>[A-Za-z@]+|.)'
    environments = '\\(?:begin|end)\{(?<value>[^{}]+)\}'
    localization_tokens = '(?<value>!!(?:\^)?(?:a)?\{[^{}]+\}s?)'
    labels = '(?<value>\\(?:ollabel|label)\{[^{}]+\})'
    references = '(?<value>\\(?:olref|Olref)(?:\[[^\]]*\]){0,3}\{[^{}]+\}|\\(?:ref|pageref|eqref)\{[^{}]+\})'
    citations = '(?<value>\\cite[a-zA-Z]*(?:\[[^\]]*\])?\{[^{}]+\})'
    imports = '(?<value>\\olimport\*?(?:\[[^\]]*\])?\{[^{}]+\})'
    assets = '(?<value>\\olasset(?:\[[^\]]*\])?\{[^{}]+\})'
    href_urls = '\\href\{(?<value>[^{}]+)\}\{'
    url_commands = '\\url\{(?<value>[^{}]+)\}'
    raw_urls = '(?<value>https?://[^\s{}]+)'
    documentclass = '(?<value>\\documentclass\[[^\]]+\]\{subfiles\})'
}

for ($fileIndex = 0; $fileIndex -lt $files.Count; $fileIndex++) {
    $record = $files[$fileIndex]
    $sourceRelative = $record.Source
    if (-not $manifestByPath.ContainsKey($sourceRelative)) {
        throw "Source missing from closure manifest: $sourceRelative"
    }
    $row = $manifestByPath[$sourceRelative]
    if ($row.closure_id -cne $record.ClosureId) {
        throw "Closure mismatch for ${sourceRelative}: expected=$($record.ClosureId) actual=$($row.closure_id)"
    }
    if ([int]$row.stable_order -ne 49 + $fileIndex) {
        throw "Stable-order mismatch for ${sourceRelative}: expected=$([int](49 + $fileIndex)) actual=$($row.stable_order)"
    }
    $expectedTargetRelative = $sourceRelative -replace '^content/', 'locale/id/content/'
    if ($row.target_path -cne $expectedTargetRelative) {
        throw "Target-path mismatch for ${sourceRelative}: expected=$expectedTargetRelative actual=$($row.target_path)"
    }
    $checks++

    $sourcePath = Join-Path $repoRoot ($sourceRelative -replace '/', '\')
    $targetPath = Join-Path $repoRoot ($expectedTargetRelative -replace '/', '\')
    if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) { throw "Source missing: $sourcePath" }
    if (-not (Test-Path -LiteralPath $targetPath -PathType Leaf)) { throw "Target missing: $targetPath" }

    $sourceHash = Get-Sha256 $sourcePath
    if ($sourceHash -cne $record.SourceSha256 -or
        $sourceHash -cne $row.source_sha256.ToLowerInvariant()) {
        throw "Source hash mismatch for ${sourceRelative}: expected=$($record.SourceSha256) manifest=$($row.source_sha256) disk=$sourceHash"
    }
    $checks++

    $targetHash = Get-Sha256 $targetPath
    if ($targetHash -cne $record.TargetSha256) {
        throw "Target hash mismatch for ${sourceRelative}: expected=$($record.TargetSha256) disk=$targetHash"
    }
    $checks++

    $sourceRaw = Normalize-AdmittedSourceCorrections `
        -SourceRelative $sourceRelative `
        -Text ([IO.File]::ReadAllText($sourcePath))
    $sourceRaw = Normalize-TranslatedReaderOrdering `
        -SourceRelative $sourceRelative -Text $sourceRaw
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
            # English na\"ive uses a lexical TeX accent. Indonesian naif does
            # not. Quoted names such as Schr\"oder remain invariant; filtering
            # this lexical command on both sides is the sole command exception.
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

    $sourceChapterIds = @(Get-Sequence -Text $source -Pattern '\\olchapter\{(?<value>[^{}]+\}\{[^{}]+)\}\{')
    $targetChapterIds = @(Get-Sequence -Text $target -Pattern '\\olchapter\{(?<value>[^{}]+\}\{[^{}]+)\}\{')
    Assert-Sequence -Name "$sourceRelative/chapter-ids" `
        -Expected $sourceChapterIds -Actual $targetChapterIds

    Assert-Sequence -Name "$sourceRelative/math-token-skeletons" `
        -Expected @(Get-MathSkeletons $source) `
        -Actual @(Get-MathSkeletons $target)
}

$cardTargetPath = Join-Path $localeRoot 'content\sets-functions-relations\infinite\card-sb.tex'
$cardTarget = Normalize-Newlines ([IO.File]::ReadAllText($cardTargetPath))
Assert-ContainsOrdinal -Name 'card-sb/sbhelper-consequent' -Text $cardTarget `
    -Required 'Jika $A \subseteq B \subseteq C$ dan $A \approx C$, maka $\cardeq{B}{C}$.' `
    -Rejected '$\cardeq{\cardeq{A}{B}}{C}$'

$requiredRangeRepair = 'Tinggal ditunjukkan bahwa $\ran{g} = B$. Pertama,' + "`n" +
    '$\ran{g} \subseteq B$: jika $x \in F$, maka $g(x)=f(x) \in A \subseteq B$;' + "`n" +
    'jika $x \notin F$, maka $x \in B$ karena $C\setminus B \subseteq F$, dan' + "`n" +
    'karena itu $g(x)=x \in B$. Untuk inklusi sebaliknya, tetapkan' + "`n" +
    '$x \in B \subseteq C$.'
Assert-ContainsOrdinal -Name 'card-sb/range-subset-inclusion' -Text $cardTarget `
    -Required $requiredRangeRepair `
    -Rejected 'Tinggal ditunjukkan bahwa $\ran{g} = B$. Jadi, tetapkan'

$dedekindSourcePath = Join-Path $repoRoot 'content\sets-functions-relations\infinite\dedekind-algebra.tex'
$dedekindTargetPath = Join-Path $localeRoot 'content\sets-functions-relations\infinite\dedekind-algebra.tex'
$dedekindSource = Normalize-Newlines ([IO.File]::ReadAllText($dedekindSourcePath))
$dedekindTarget = Normalize-Newlines ([IO.File]::ReadAllText($dedekindTargetPath))

# Adverse evidence is deliberately preserved. The frozen lemma quantifies an
# unbound A, while the definition says "any function" even though the proof's
# range-union witness needs an endofunction/domain premise.
Assert-ContainsOrdinal -Name 'adverse/unbound-A/source' -Kind adverse -Text $dedekindSource `
    -Required 'For any function $f$ and any $o \in A$:'
Assert-ContainsOrdinal -Name 'adverse/unbound-A/target-preserved' -Kind adverse -Text $dedekindTarget `
    -Required 'Untuk sembarang fungsi $f$ dan sembarang $o \in A$:'
Assert-ContainsOrdinal -Name 'adverse/endofunction-premise/target-preserved' -Kind adverse -Text $dedekindTarget `
    -Required ('Untuk sembarang fungsi $f$, himpunan $X$ bersifat $f$-\emph{tertutup}' + "`n" +
        "`t" + '{jika dan hanya jika} $(\forall x \in X)f(x) \in X$.')

if ($sourceCorrections -ne 2) {
    throw "Source-correction count mismatch: expected=2 actual=$sourceCorrections"
}
if ($readerTextExceptions -ne 1) {
    throw "Reader-text exception count mismatch: expected=1 actual=$readerTextExceptions"
}
if ($targetCorrectionAssertions -ne 2) {
    throw "Target-correction assertion count mismatch: expected=2 actual=$targetCorrectionAssertions"
}
if ($adverseAssertions -ne 3) {
    throw "Adverse-assertion count mismatch: expected=3 actual=$adverseAssertions"
}

"INFINITE_BATCH_REPLAY_OK files=$($files.Count) checks=$checks source_corrections=$sourceCorrections reader_text_exceptions=$readerTextExceptions target_corrections=$targetCorrectionAssertions adverse_assertions=$adverseAssertions upstream=$expectedCommit closure=OLP-0049..OLP-0054"
