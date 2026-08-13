$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$localeRoot = $PSScriptRoot
$repoRoot = [IO.Path]::GetFullPath((Join-Path $localeRoot '..\..'))
$controlRoot = [IO.Path]::GetFullPath((Join-Path $repoRoot '..\_control'))
$manifestPath = Join-Path $controlRoot 'OPENLOGIC_CLOSURE_MANIFEST_20260812.csv'
$expectedCommit = '9620cc73f9c8e0ad003c514a5d3748f29611c4c0'

$files = @(
    [pscustomobject]@{
        ClosureId = 'OLP-0055'
        Source = 'content/propositional-logic/propositional-logic.tex'
        SourceSha256 = '8cfcb14b29eae3ae53c6ef626987e2323b8c870010e27d52d454296f24452799'
        TargetSha256 = 'fbcb8684894f2c907d5b42a0b93a3b568edc30b7fab8f6f39d48217b1f271b4c'
    }
    [pscustomobject]@{
        ClosureId = 'OLP-0056'
        Source = 'content/propositional-logic/syntax-and-semantics/syntax-and-semantics.tex'
        SourceSha256 = '799d1dab63cda19a28c1dbf7097052fb790bbce609aecd5367d2e368decdb18b'
        TargetSha256 = '462431e7b2bce9ecb44ca9b5ee98870a39e2921d78c2e7f2954a968e4aafa195'
    }
    [pscustomobject]@{
        ClosureId = 'OLP-0057'
        Source = 'content/propositional-logic/syntax-and-semantics/introduction.tex'
        SourceSha256 = '2ad06497283fa1399d56862c75caf1a418bb753fbb0195658af9f0c57183a441'
        TargetSha256 = '755779eaec9923d35a349eb526b3af07b9f07b3a20b41e5423bd009f837a4c9d'
    }
    [pscustomobject]@{
        ClosureId = 'OLP-0058'
        Source = 'content/propositional-logic/syntax-and-semantics/formulas.tex'
        SourceSha256 = '8777d77e48e3a41a527b1b737c67e00cb7850f4fa0902ce24846000b40724756'
        TargetSha256 = '102d32ad31976a33e2846eac0c86f6fe5efd2d864ade0a0095cff5b624b77efa'
    }
    [pscustomobject]@{
        ClosureId = 'OLP-0059'
        Source = 'content/propositional-logic/syntax-and-semantics/preliminaries.tex'
        SourceSha256 = '78673f8419aa1f936f1ecc5629c0fa92c74fd4ee3102badf5f389e3d775f48d6'
        TargetSha256 = 'df60b0058fd7d79d8b369ebdb98d5ca109093aa2c0ed99badf87e1a4500edb2e'
    }
    [pscustomobject]@{
        ClosureId = 'OLP-0060'
        Source = 'content/propositional-logic/syntax-and-semantics/formation-sequences.tex'
        SourceSha256 = '4057bf6b85c70ad9ee56dc5365b21a1daa0a99550079bdafb1ab16f36b943356'
        TargetSha256 = '72801592ce5a90faf543cf23558731abb1b7239f109821f6bc6edbf2ab3b5777'
    }
    [pscustomobject]@{
        ClosureId = 'OLP-0061'
        Source = 'content/propositional-logic/syntax-and-semantics/valuations-sat.tex'
        SourceSha256 = 'd1454e8c2366f3a204a371523f41feacbdc72402f7a3a7ae6635b60b17c90481'
        TargetSha256 = '22b344cb5a7008a0cb27236055077a9fa505e35bf9b4349ef4b39a1512577677'
    }
    [pscustomobject]@{
        ClosureId = 'OLP-0062'
        Source = 'content/propositional-logic/syntax-and-semantics/semantic-notions.tex'
        SourceSha256 = '0167b2bab0dc2a75d011556643190a246d29831244a60bde5515b1b2f431406a'
        TargetSha256 = '1e32925e1d401747f5ac5b73403884083b85efd85f70d708bad9c66369580115'
    }
)

$manifest = Import-Csv -LiteralPath $manifestPath
$manifestByPath = @{}
foreach ($row in $manifest) { $manifestByPath[$row.source_path] = $row }

$checks = 0
$mathSkeletons = 0
$sourceCorrections = 0
$readerOrderExceptions = 0
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
            for ($left = $index - 1; $left -ge 0 -and $line[$left] -eq '\'; $left--) {
                $slashes++
            }
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
        if ($Text[$index] -ne '{' -and $Text[$index] -ne '}') { continue }
        $slashes = 0
        for ($left = $index - 1; $left -ge 0 -and $Text[$left] -eq '\'; $left--) {
            $slashes++
        }
        if (($slashes % 2) -eq 1) { continue }
        if ($Text[$index] -eq '{') { $balance++ } else { $balance-- }
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
    $script:readerOrderExceptions++
    return $Text.Substring(0, $position) + $New + $Text.Substring($position + $Old.Length)
}

function Normalize-AdmittedSourceCorrections {
    param(
        [Parameter(Mandatory)][string]$SourceRelative,
        [Parameter(Mandatory)][string]$Text
    )
    $Text = Normalize-Newlines $Text
    if ($SourceRelative -ceq 'content/propositional-logic/syntax-and-semantics/formulas.tex') {
        $Text = Replace-RequiredOrdinal -Text $Text `
            -Old '  \iftag{defTrue}{\ycomma $\ltrue$ (!!{truth})}}{}.' `
            -New '  \iftag{defTrue}{\ycomma $\ltrue$ (!!{truth})}{}.}{}' `
            -Name 'formulas/conditional-period'
        $Text = Replace-RequiredOrdinal -Text $Text `
            -Old '\iftag{prvOr}{$\lnot !A \lor !B)$}' `
            -New '\iftag{prvOr}{$\lnot !A \lor !B$}' `
            -Name 'formulas/implication-prvOr-math'
    }
    if ($SourceRelative -ceq 'content/propositional-logic/syntax-and-semantics/formation-sequences.tex') {
        $Text = Replace-RequiredOrdinal -Text $Text `
            -Old 'Suppose instead that $!A \equiv' `
            -New 'Suppose instead that $!A \ident' `
            -Name 'formation-sequences/syntactic-identity'
    }
    return $Text
}

function Normalize-TranslatedReaderOrdering {
    param(
        [Parameter(Mandatory)][string]$SourceRelative,
        [Parameter(Mandatory)][string]$Text
    )
    if ($SourceRelative -cne 'content/propositional-logic/syntax-and-semantics/formulas.tex') {
        return $Text
    }
    return Replace-ReaderOrderingOrdinal -Text $Text `
        -Old '!!^a{denumerable} set~$\PVar$' `
        -New 'Set !!a{denumerable}~$\PVar$' `
        -Name 'formulas/denumerable-noun-order'
}

function Assert-CorrectedTargetForm {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string]$Required,
        [Parameter(Mandatory)][string]$Rejected
    )
    if ($Text.IndexOf($Required, [StringComparison]::Ordinal) -lt 0) {
        throw "Required corrected form missing: $Name"
    }
    if ($Text.IndexOf($Rejected, [StringComparison]::Ordinal) -ge 0) {
        throw "Rejected frozen-source form remains: $Name"
    }
    $script:correctionAssertions++
}

function Assert-TargetText {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string]$Required,
        [AllowEmptyString()][string]$Rejected = ''
    )
    if ($Text.IndexOf($Required, [StringComparison]::Ordinal) -lt 0) {
        throw "Required target text missing: $Name"
    }
    if ($Rejected.Length -gt 0 -and
        $Text.IndexOf($Rejected, [StringComparison]::Ordinal) -ge 0) {
        throw "Rejected target text remains: $Name"
    }
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
    urls = '(?<value>\\href\{[^{}]+\}\{|\\url\{[^{}]+\}|https?://[^\s{}]+)'
    documentclass = '(?<value>\\documentclass\[[^\]]+\]\{subfiles\})'
}

$null = & git -C $repoRoot merge-base --is-ancestor $expectedCommit HEAD
if ($LASTEXITCODE -ne 0) {
    throw "Authority mismatch: frozen source commit $expectedCommit is not an ancestor of HEAD"
}

for ($fileIndex = 0; $fileIndex -lt $files.Count; $fileIndex++) {
    $record = $files[$fileIndex]
    $sourceRelative = $record.Source
    $targetRelative = $sourceRelative -replace '^content/', 'locale/id/content/'

    if (-not $manifestByPath.ContainsKey($sourceRelative)) {
        throw "Source missing from closure manifest: $sourceRelative"
    }
    $row = $manifestByPath[$sourceRelative]
    if ($row.closure_id -cne $record.ClosureId) {
        throw "Closure mismatch for ${sourceRelative}: expected=$($record.ClosureId) actual=$($row.closure_id)"
    }
    if ([int]$row.stable_order -ne 55 + $fileIndex) {
        throw "Stable-order mismatch for ${sourceRelative}: expected=$([int](55 + $fileIndex)) actual=$($row.stable_order)"
    }
    if ($row.target_path -cne $targetRelative) {
        throw "Target-path mismatch for ${sourceRelative}: expected=$targetRelative actual=$($row.target_path)"
    }
    if ($row.source_sha256.ToLowerInvariant() -cne $record.SourceSha256) {
        throw "Manifest source hash mismatch for $sourceRelative"
    }

    $sourcePath = Join-Path $repoRoot ($sourceRelative -replace '/', '\')
    $targetPath = Join-Path $repoRoot ($targetRelative -replace '/', '\')
    if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) { throw "Source missing: $sourcePath" }
    if (-not (Test-Path -LiteralPath $targetPath -PathType Leaf)) { throw "Target missing: $targetPath" }
    if ((Get-Sha256 $sourcePath) -cne $record.SourceSha256) {
        throw "Source hash mismatch for $sourceRelative"
    }
    if ((Get-Sha256 $targetPath) -cne $record.TargetSha256) {
        throw "Target hash mismatch for $targetRelative"
    }
    $null = & git -C $repoRoot diff --quiet $expectedCommit -- $sourceRelative
    if ($LASTEXITCODE -ne 0) {
        throw "Frozen source differs from authority commit: $sourceRelative"
    }

    $sourceRaw = Normalize-AdmittedSourceCorrections `
        -SourceRelative $sourceRelative `
        -Text ([IO.File]::ReadAllText($sourcePath))
    $sourceRaw = Normalize-TranslatedReaderOrdering `
        -SourceRelative $sourceRelative `
        -Text $sourceRaw
    $source = Remove-TexComments $sourceRaw
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

    $sourceIds = @(Get-Sequence -Text $source `
        -Pattern '(?<value>\\olfileid\{[^{}]+\}\{[^{}]+\}\{[^{}]+\})')
    $expectedIds = @($sourceIds | ForEach-Object {
        $_ -replace '^\\olfileid', '\olfileid[id]'
    })
    $targetIds = @(Get-Sequence -Text $target `
        -Pattern '(?<value>\\olfileid\[id\]\{[^{}]+\}\{[^{}]+\}\{[^{}]+\})')
    Assert-Sequence -Name "$sourceRelative/file-ids" `
        -Expected $expectedIds -Actual $targetIds

    $sourceChapterIds = @(Get-Sequence -Text $source `
        -Pattern '\\olchapter\{(?<value>[^{}]+\}\{[^{}]+)\}\{')
    $targetChapterIds = @(Get-Sequence -Text $target `
        -Pattern '\\olchapter\{(?<value>[^{}]+\}\{[^{}]+)\}\{')
    Assert-Sequence -Name "$sourceRelative/chapter-ids" `
        -Expected $sourceChapterIds -Actual $targetChapterIds

    $sourceMath = @(Get-MathSkeletons $source)
    $targetMath = @(Get-MathSkeletons $target)
    Assert-Sequence -Name "$sourceRelative/math-token-skeletons" `
        -Expected $sourceMath -Actual $targetMath
    $mathSkeletons += $sourceMath.Count
}

$introductionTarget = Normalize-Newlines ([IO.File]::ReadAllText((Join-Path $repoRoot `
    'locale\id\content\propositional-logic\syntax-and-semantics\introduction.tex')))
$formulasTarget = Normalize-Newlines ([IO.File]::ReadAllText((Join-Path $repoRoot `
    'locale\id\content\propositional-logic\syntax-and-semantics\formulas.tex')))
$formationTarget = Normalize-Newlines ([IO.File]::ReadAllText((Join-Path $repoRoot `
    'locale\id\content\propositional-logic\syntax-and-semantics\formation-sequences.tex')))
$valuationsTarget = Normalize-Newlines ([IO.File]::ReadAllText((Join-Path $repoRoot `
    'locale\id\content\propositional-logic\syntax-and-semantics\valuations-sat.tex')))

Assert-CorrectedTargetForm -Name 'formulas/conditional-period' -Text $formulasTarget `
    -Required '  \iftag{defTrue}{\ycomma $\ltrue$ (!!{truth})}{}.}{}' `
    -Rejected '  \iftag{defTrue}{\ycomma $\ltrue$ (!!{truth})}}{}.'
Assert-CorrectedTargetForm -Name 'formulas/implication-prvOr-math' -Text $formulasTarget `
    -Required '\iftag{prvOr}{$\lnot !A \lor !B$}{$\lnot (!A \land \lnot !B)$}' `
    -Rejected '\iftag{prvOr}{$\lnot !A \lor !B)$}'
Assert-CorrectedTargetForm -Name 'formation-sequences/syntactic-identity' -Text $formationTarget `
    -Required 'Sebaliknya, andaikan $!A \ident' `
    -Rejected 'Sebaliknya, andaikan $!A \equiv'

Assert-TargetText -Name 'formulas/denumerable-noun-order' -Text $formulasTarget `
    -Required '\item Himpunan !!a{denumerable}~$\PVar$ dari' `
    -Rejected '\item !!^a{denumerable}'
Assert-TargetText -Name 'introduction/consequence-direction' -Text $introductionTarget `
    -Required 'Formula itu merupakan konsekuensi semantis dari suatu himpunan'
Assert-TargetText -Name 'formation-sequences/final-index-induction' -Text $formationTarget `
    -Required 'setiap untai simbol dengan barisan pembentukan berindeks terakhir $m < n$'
Assert-TargetText -Name 'formation-sequences/prefix-final-index' -Text $formationTarget `
    -Required 'terakhir keduanya lebih kecil daripada~$n$'
Assert-TargetText -Name 'valuations/fixed-formula-scope' -Text $valuationsTarget `
    -Required 'muncul dalam !!{formula}~$!A$.' `
    -Rejected 'muncul dalam suatu !!{formula}~$!A$.'

if ($checks -ne 112) {
    throw "Structural check count mismatch: expected=112 actual=$checks"
}
if ($mathSkeletons -ne 424) {
    throw "Math-skeleton count mismatch: expected=424 actual=$mathSkeletons"
}
if ($sourceCorrections -ne 3) {
    throw "Source-correction count mismatch: expected=3 actual=$sourceCorrections"
}
if ($readerOrderExceptions -ne 1) {
    throw "Reader-order exception count mismatch: expected=1 actual=$readerOrderExceptions"
}
if ($correctionAssertions -ne 3) {
    throw "Correction-assertion count mismatch: expected=3 actual=$correctionAssertions"
}

"PROP_SYNTAX_REPLAY_OK files=$($files.Count) checks=$checks math_skeletons=$mathSkeletons reader_order_exceptions=$readerOrderExceptions source_corrections=$sourceCorrections correction_assertions=$correctionAssertions closure=OLP-0055..OLP-0062 upstream=$expectedCommit"
