$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$localeRoot = $PSScriptRoot
$repoRoot = [IO.Path]::GetFullPath((Join-Path $localeRoot '..\..'))
$controlRoot = [IO.Path]::GetFullPath((Join-Path $repoRoot '..\_control'))
$manifestPath = Join-Path $controlRoot 'OPENLOGIC_CLOSURE_MANIFEST_20260812.csv'
$expectedCommit = '9620cc73f9c8e0ad003c514a5d3748f29611c4c0'

$units = @(
    [pscustomobject]@{
        Id = 'OLP-0063'
        Name = 'proof-systems.tex'
        SourceHash = '85b8a0fca16c329ad16b3c17975735c159e0cf9d38e8dfc7501acba84171fb6c'
        TargetHash = '907af9733ac30d4d49d72a40cb7af244e9800ce7ebf7e3785377e24ecd397a31'
        SourceWords = 49
        TargetWords = 46
    }
    [pscustomobject]@{
        Id = 'OLP-0064'
        Name = 'introduction.tex'
        SourceHash = '5172343625a0d66971257858a1a6e359805ffeec979bd5afdc0377864799a756'
        TargetHash = 'f0fd9207187515506bd4f7eb6b71e98bf4be578af14d0908eb2649eab7d44f8c'
        SourceWords = 706
        TargetWords = 641
    }
    [pscustomobject]@{
        Id = 'OLP-0065'
        Name = 'sequent-calculus.tex'
        SourceHash = '9a847c7bd45afe0d177230807fb2ba9dda820b4c0551a9274002db8776182003'
        TargetHash = '04fe414e682651cbbf0b1d7aca69f7c533a38f8ae92acd2ab1321ec9199726bf'
        SourceWords = 357
        TargetWords = 296
    }
    [pscustomobject]@{
        Id = 'OLP-0066'
        Name = 'natural-deduction.tex'
        SourceHash = 'c203daa5161eed34188e9fb9022b83be4f0201904f31cef386c5b838fb9e7d49'
        TargetHash = '4200eced3b9252a4a58760382628c530faf282150165ff730373cf0e38508ff2'
        SourceWords = 612
        TargetWords = 519
    }
    [pscustomobject]@{
        Id = 'OLP-0067'
        Name = 'tableaux.tex'
        SourceHash = '6abf691f97c618dd41bc0c30a21dcf74fa7025228aa378cfd9f0369a898c2966'
        TargetHash = '4d61a7b695b9eb0ca94a91684fd0f98ffe209439914e7d189ae9dabacfa1781e'
        SourceWords = 472
        TargetWords = 438
    }
    [pscustomobject]@{
        Id = 'OLP-0068'
        Name = 'axiomatic-deduction.tex'
        SourceHash = '0269390efeb94a0522020ce00d45f1d1e752e4a32db564b7519d7a939fa13034'
        TargetHash = 'ace4b2e3d141b1df2102fd32d6d4cbc286ba4f0abd7ec75d5221f9be24791efe'
        SourceWords = 535
        TargetWords = 479
    }
)

$sourceDir = Join-Path $repoRoot 'content\first-order-logic\proof-systems'
$targetDir = Join-Path $localeRoot 'content\first-order-logic\proof-systems'
$checks = 0
$totals = [ordered]@{
    commands = 0
    environments = 0
    localization_tokens = 0
    labels = 0
    references = 0
    citations = 0
    assets = 0
    imports = 0
    math_skeletons = 0
    proof_blocks = 0
    localized_file_ids = 0
}

function Get-Sha256 {
    param([Parameter(Mandatory)][string]$Path)
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function Get-Sequence {
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string]$Pattern
    )
    return @([regex]::Matches(
        $Text,
        $Pattern,
        [Text.RegularExpressions.RegexOptions]::Singleline
    ) | ForEach-Object { $_.Groups['value'].Value })
}

function Assert-Sequence {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Expected,
        [Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Actual
    )
    if ($Expected.Count -ne $Actual.Count) {
        throw "$Name count mismatch: expected=$($Expected.Count), actual=$($Actual.Count)"
    }
    for ($index = 0; $index -lt $Expected.Count; $index++) {
        if ([string]$Expected[$index] -cne [string]$Actual[$index]) {
            throw "$Name mismatch at index $index`nEXPECTED: $($Expected[$index])`nACTUAL: $($Actual[$index])"
        }
    }
    $script:checks++
    Write-Output "PASS $Name count=$($Expected.Count)"
}

function Assert-RegexCount {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string]$Pattern,
        [Parameter(Mandatory)][int]$Expected
    )
    $actual = ([regex]::Matches(
        $Text,
        $Pattern,
        [Text.RegularExpressions.RegexOptions]::Singleline
    )).Count
    if ($actual -ne $Expected) {
        throw "$Name occurrence mismatch: expected=$Expected, actual=$actual"
    }
    $script:checks++
    Write-Output "PASS $Name count=$actual"
}

function Replace-Exact {
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string]$Old,
        [Parameter(Mandatory)][string]$New,
        [Parameter(Mandatory)][int]$ExpectedCount,
        [Parameter(Mandatory)][string]$Name
    )
    $actual = ([regex]::Matches($Text, [regex]::Escape($Old))).Count
    if ($actual -ne $ExpectedCount) {
        throw "$Name source occurrence mismatch: expected=$ExpectedCount, actual=$actual"
    }
    return $Text.Replace($Old, $New)
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
    return @($segments)
}

function Get-ProofBlocks {
    param([Parameter(Mandatory)][string]$Text)
    return @([regex]::Matches(
        $Text,
        '\\begin\{(?<environment>prooftree|oltableau|derivation)\}(?<body>.*?)\\end\{\k<environment>\}',
        [Text.RegularExpressions.RegexOptions]::Singleline
    ) | ForEach-Object {
        $_.Groups['environment'].Value + ':' +
            [regex]::Replace($_.Groups['body'].Value, '\s+', '')
    })
}

function Get-TexcountWords {
    param([Parameter(Mandatory)][string]$Path)
    $output = @(& texcount -sum -1 -utf8 $Path 2>$null)
    if ($LASTEXITCODE -ne 0 -or $output.Count -eq 0) {
        throw "TeXcount failed for $Path"
    }
    $value = 0
    if (-not [int]::TryParse(([string]$output[-1]).Trim(), [ref]$value)) {
        throw "Unexpected TeXcount result for ${Path}: $($output -join ' | ')"
    }
    return $value
}

function Get-CorrectedSourceForReplay {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Text
    )
    $result = $Text
    if ($Name -ceq 'sequent-calculus.tex') {
        $result = Replace-Exact -Text $result `
            -Old '!A_1, \dots, !A_m \Sequent !B_1, \dots, !B_m,' `
            -New '!A_1, \dots, !A_m \Sequent !B_1, \dots, !B_n,' `
            -ExpectedCount 1 -Name 'sequent-right-endpoint'
    }
    if ($Name -ceq 'tableaux.tex') {
        $result = Replace-Exact -Text $result `
            -Old '\TRule{\False}{!A \land !B}' `
            -New '\TRule{\False}{\land}' `
            -ExpectedCount 1 -Name 'false-conjunction-rule-name'
        $result = Replace-Exact -Text $result `
            -Old '\TRule{\True}{\lif}[2]' `
            -New '\TRule{\True}{\land}[2]' `
            -ExpectedCount 2 -Name 'true-conjunction-proof-labels'
    }
    return $result
}

function Remove-NonReaderSurface {
    param([Parameter(Mandatory)][string]$Text)
    $result = [regex]::Replace($Text, '(?m)(?<!\\)%.*$', '')
    $result = [regex]::Replace(
        $result,
        '\\begin\{(?:prooftree|oltableau|derivation)\}.*?\\end\{(?:prooftree|oltableau|derivation)\}',
        '',
        [Text.RegularExpressions.RegexOptions]::Singleline
    )
    $result = [regex]::Replace($result, '(?<!\\)\$.*?(?<!\\)\$', '', 'Singleline')
    $result = [regex]::Replace($result, '\\\[.*?\\\]', '', 'Singleline')
    $result = [regex]::Replace($result, '!!(?:\^)?(?:a|A)?\{[^{}]+\}(?:s|d)?', '')
    return $result
}

& git -C $repoRoot merge-base --is-ancestor $expectedCommit HEAD
if ($LASTEXITCODE -ne 0) {
    throw "Authority mismatch: frozen source commit $expectedCommit is not an ancestor of HEAD"
}
if (-not (Test-Path -LiteralPath $manifestPath)) {
    throw "Closure manifest missing: $manifestPath"
}
if (-not (Get-Command texcount -ErrorAction Stop)) {
    throw 'TeXcount is required for the frozen word-count replay.'
}

$manifest = Import-Csv -LiteralPath $manifestPath
$literalPatterns = [ordered]@{
    commands = '(?<value>\\[A-Za-z@]+|\\.)'
    environments = '(?<value>\\(?:begin|end)\{[^{}]+\})'
    localization_tokens = '(?<value>!!(?:\^)?(?:a|A)?\{[^{}]+\}(?:s|d)?)'
    labels = '(?<value>\\ollabel\{[^{}]+\})'
    references = '(?<value>\\(?:olref|Olref)(?:\[[^\]]*\]){0,3}\{[^{}]+\})'
    citations = '(?<value>\\cite[a-zA-Z]*\{[^{}]+\})'
    assets = '(?<value>\\olasset(?:\[[^\]]*\])?\{[^{}]+\})'
    imports = '(?<value>\\olimport\*?(?:\[[^\]]*\])?\{[^{}]+\})'
}

$sourceTotalWords = 0
$targetTotalWords = 0
$finalSource = @{}
$finalTarget = @{}

foreach ($unit in $units) {
    $sourceRelative = "content/first-order-logic/proof-systems/$($unit.Name)"
    $targetRelative = "locale/id/content/first-order-logic/proof-systems/$($unit.Name)"
    $sourcePath = Join-Path $sourceDir $unit.Name
    $targetPath = Join-Path $targetDir $unit.Name

    $rows = @($manifest | Where-Object { $_.closure_id -ceq $unit.Id })
    if ($rows.Count -ne 1) { throw "Manifest row count for $($unit.Id): $($rows.Count)" }
    $row = $rows[0]
    if ($row.source_commit -cne $expectedCommit -or
        $row.source_path -cne $sourceRelative -or
        $row.source_sha256.ToLowerInvariant() -cne $unit.SourceHash -or
        $row.target_path -cne $targetRelative) {
        throw "Manifest binding mismatch for $($unit.Id)"
    }
    $checks++
    Write-Output "PASS $($unit.Id)/manifest-binding"

    if ((Get-Sha256 $sourcePath) -cne $unit.SourceHash) {
        throw "Source hash mismatch for $sourceRelative"
    }
    if ((Get-Sha256 $targetPath) -cne $unit.TargetHash) {
        throw "Target hash mismatch for $targetRelative"
    }
    $checks += 2
    Write-Output "PASS $($unit.Id)/source-hash $($unit.SourceHash)"
    Write-Output "PASS $($unit.Id)/target-hash $($unit.TargetHash)"

    $sourceWords = Get-TexcountWords $sourcePath
    $targetWords = Get-TexcountWords $targetPath
    if ($sourceWords -ne $unit.SourceWords -or $targetWords -ne $unit.TargetWords) {
        throw "$($unit.Id) word-count mismatch: source=$sourceWords/$($unit.SourceWords), target=$targetWords/$($unit.TargetWords)"
    }
    $sourceTotalWords += $sourceWords
    $targetTotalWords += $targetWords
    $checks++
    Write-Output "PASS $($unit.Id)/texcount source=$sourceWords target=$targetWords"

    # Hashes bind the raw bytes above; normalize line endings only for the
    # cross-platform structural comparison that follows.
    $source = [IO.File]::ReadAllText($sourcePath).Replace("`r`n", "`n")
    $target = [IO.File]::ReadAllText($targetPath).Replace("`r`n", "`n")
    $sourceForReplay = Get-CorrectedSourceForReplay -Name $unit.Name -Text $source
    $finalSource[$unit.Name] = $source
    $finalTarget[$unit.Name] = $target

    if ((Get-BraceBalance $source) -ne 0 -or (Get-BraceBalance $target) -ne 0) {
        throw "Brace balance failed for $($unit.Id)"
    }
    $checks++
    Write-Output "PASS $($unit.Id)/brace-balance"

    foreach ($entry in $literalPatterns.GetEnumerator()) {
        $sourceSequence = @(Get-Sequence -Text $sourceForReplay -Pattern $entry.Value)
        $targetSequence = @(Get-Sequence -Text $target -Pattern $entry.Value)
        if ($entry.Key -eq 'localization_tokens') {
            # Three English passive suffix constructions cannot be carried
            # into Indonesian. The sentence-initial English article on
            # "derivation system" must also move before the reordered
            # Indonesian compound "sistem derivasi". Exact target prose for
            # both morphology classes is asserted below.
            $sourceSequence = @($sourceSequence | Where-Object { $_ -cne '!!{derive}d' })
            if ($unit.Name -eq 'introduction.tex') {
                $sourceSequence = @($sourceSequence | ForEach-Object {
                    if ($_ -ceq '!!^a{derivation}') { '!!{derivation}' } else { $_ }
                })
            }
        }
        Assert-Sequence -Name "$($unit.Id)/$($entry.Key)" `
            -Expected $sourceSequence -Actual $targetSequence
        $totals[$entry.Key] += $sourceSequence.Count
    }

    $sourceIds = @(Get-Sequence -Text $source -Pattern '(?<value>\\olfileid\{[^{}]+\}\{[^{}]+\}\{[^{}]+\})')
    $expectedIds = @($sourceIds | ForEach-Object { $_ -replace '^\\olfileid', '\olfileid[id]' })
    $targetIds = @(Get-Sequence -Text $target -Pattern '(?<value>\\olfileid\[id\]\{[^{}]+\}\{[^{}]+\}\{[^{}]+\})')
    Assert-Sequence -Name "$($unit.Id)/localized-file-ids" -Expected $expectedIds -Actual $targetIds
    $totals.localized_file_ids += $expectedIds.Count

    $sourceChapterIds = @(Get-Sequence -Text $source -Pattern '\\olchapter\{(?<value>[^{}]+\}\{[^{}]+)\}\{')
    $targetChapterIds = @(Get-Sequence -Text $target -Pattern '\\olchapter\{(?<value>[^{}]+\}\{[^{}]+)\}\{')
    Assert-Sequence -Name "$($unit.Id)/chapter-ids" -Expected $sourceChapterIds -Actual $targetChapterIds

    $sourceMath = @(Get-MathSkeletons $sourceForReplay)
    $targetMath = @(Get-MathSkeletons $target)
    Assert-Sequence -Name "$($unit.Id)/math-skeletons" -Expected $sourceMath -Actual $targetMath
    $totals.math_skeletons += $sourceMath.Count

    $sourceProofs = @(Get-ProofBlocks $sourceForReplay)
    $targetProofs = @(Get-ProofBlocks $target)
    Assert-Sequence -Name "$($unit.Id)/proof-blocks" -Expected $sourceProofs -Actual $targetProofs
    $totals.proof_blocks += $sourceProofs.Count
}

if ($sourceTotalWords -ne 2731 -or $targetTotalWords -ne 2419) {
    throw "Batch word totals mismatch: source=$sourceTotalWords, target=$targetTotalWords"
}
$checks++
Write-Output "PASS batch/texcount-totals source=$sourceTotalWords target=$targetTotalWords"

# Bind every deliberate exception to exact source and target wording.
$sequenceSource = $finalSource['sequent-calculus.tex']
$sequenceTarget = $finalTarget['sequent-calculus.tex']
Assert-RegexCount -Name 'correction/sequent-source-B_m' -Text $sequenceSource `
    -Pattern '!A_1, \\dots, !A_m \\Sequent !B_1, \\dots, !B_m,' -Expected 1
Assert-RegexCount -Name 'correction/sequent-target-B_n' -Text $sequenceTarget `
    -Pattern '!A_1, \\dots, !A_m \\Sequent !B_1, \\dots, !B_n,' -Expected 1

$tableauSource = $finalSource['tableaux.tex']
$tableauTarget = $finalTarget['tableaux.tex']
Assert-RegexCount -Name 'correction/tableau-source-malformed-F-and-rule' -Text $tableauSource `
    -Pattern '\\TRule\{\\False\}\{!A \\land !B\}' -Expected 1
Assert-RegexCount -Name 'correction/tableau-target-connective-F-and-rule' -Text $tableauTarget `
    -Pattern '\\TRule\{\\False\}\{\\land\}' -Expected 1
Assert-RegexCount -Name 'correction/tableau-source-wrong-T-implication-labels' -Text $tableauSource `
    -Pattern '\\TRule\{\\True\}\{\\lif\}\[2\]' -Expected 2
Assert-RegexCount -Name 'correction/tableau-target-T-conjunction-labels' -Text $tableauTarget `
    -Pattern '\\TRule\{\\True\}\{\\land\}\[2\]' -Expected 2
Assert-RegexCount -Name 'correction/tableau-source-existential-B_i' -Text $tableauSource `
    -Pattern 'for some \$!B_i \\in \\Gamma\$\.' -Expected 1
Assert-RegexCount -Name 'correction/tableau-target-universal-finite-list' -Text $tableauTarget `
    -Pattern 'dengan syarat \$!B_i \\in \\Gamma\$ berlaku untuk setiap indeks dalam\s+daftar berhingga tersebut\.' -Expected 1
Assert-RegexCount -Name 'correction/tableau-source-unrestricted-subformula-claim' -Text $tableauSource `
    -Pattern 'A rule applied to a complex !!\{signed formula\} results in the addition\s+of !!\{signed formula\}s which are immediate sub-!!\{formula\}s\.' -Expected 1
Assert-RegexCount -Name 'correction/tableau-target-connective-quantifier-qualification' -Text $tableauTarget `
    -Pattern 'Aturan penghubung yang diterapkan pada !!\{signed formula\} kompleks\s+menghasilkan penambahan !!\{signed formula\}s yang merupakan\s+sub-!!\{formula\}s langsung; aturan kuantor dapat menghasilkan instans\s+substitusi dari suatu subformula\.' -Expected 1

$axiomaticSource = $finalSource['axiomatic-deduction.tex']
$axiomaticTarget = $finalTarget['axiomatic-deduction.tex']
Assert-RegexCount -Name 'correction/axiomatic-source-exact-Gamma' -Text $axiomaticSource `
    -Pattern '\(and \$\\Gamma\$ is taken as the\s+set of !!\{sentence\}s in that !!\{derivation\} which are justified by~\(2\) above\)\.' -Expected 1
Assert-RegexCount -Name 'correction/axiomatic-target-finite-used-subset' -Text $axiomaticTarget `
    -Pattern '\(dan himpunan berhingga !!\{sentence\}s dalam !!\{derivation\} tersebut\s+yang dijustifikasi oleh~\(2\) di atas merupakan himpunan bagian\s+dari~\$\\Gamma\$\)\.' -Expected 1

$naturalTarget = $finalTarget['natural-deduction.tex']
Assert-RegexCount -Name 'review/natural-intermediate-step' -Text $naturalTarget `
    -Pattern 'langkah perantara' -Expected 1
Assert-RegexCount -Name 'review/natural-selected-labeled-discharge' -Text $naturalTarget `
    -Pattern 'melepaskan asumsi-asumsi berbentuk~\$!A\$\s+yang dipilih serta diberi label untuk inferensi tersebut\.' -Expected 1

$introductionSource = $finalSource['introduction.tex']
$introductionTarget = $finalTarget['introduction.tex']
Assert-RegexCount -Name 'normalization/source-English-article-before-derivation-system' -Text $introductionSource `
    -Pattern '!!\^a\{derivation\} system is sound' -Expected 1
Assert-RegexCount -Name 'normalization/target-Indonesian-reordered-system-article' -Text $introductionTarget `
    -Pattern 'Suatu sistem !!\{derivation\} bersifat sahih' -Expected 1

$allSource = ($units | ForEach-Object { $finalSource[$_.Name] }) -join "`n"
$allTarget = ($units | ForEach-Object { $finalTarget[$_.Name] }) -join "`n"
Assert-RegexCount -Name 'normalization/source-English-passive-token' -Text $allSource `
    -Pattern '!!\{derive\}d' -Expected 3
Assert-RegexCount -Name 'normalization/target-Indonesian-passive-prose' -Text $allTarget `
    -Pattern 'dapat diturunkan' -Expected 3

$englishPhrases = @(
    'This chapter',
    'The purpose of',
    'For instance',
    'if and only if',
    'The relation',
    'as follows',
    'rule of inference',
    'truth value',
    'proof by cases',
    'conditional proof',
    'natural deduction',
    'sequent calculus',
    'axiomatic derivation',
    'from an inconsistent set',
    'at its root',
    'was invented',
    'were developed',
    'is inconsistent'
)
$residueHits = 0
foreach ($unit in $units) {
    $readerSurface = Remove-NonReaderSurface $finalTarget[$unit.Name]
    foreach ($phrase in $englishPhrases) {
        $count = ([regex]::Matches(
            $readerSurface,
            [regex]::Escape($phrase),
            [Text.RegularExpressions.RegexOptions]::IgnoreCase
        )).Count
        if ($count -gt 0) {
            throw "Reader-facing English residue in $($unit.Id): '$phrase' count=$count"
        }
        $residueHits += $count
    }
}
$checks++
Write-Output "PASS batch/untranslated-reader-facing-English hits=$residueHits"

Write-Output 'CORE_SOURCE_REPAIRS_OK classes=5 replacement_occurrences=6'
Write-Output 'FOL_SUBFORMULA_QUALIFICATION_OK classes=1'
Write-Output 'TRANSLATION_REVIEW_CORRECTIONS_OK count=2'
Write-Output 'TOKEN_MORPHOLOGY_NORMALIZATION_OK source_tokens=3 target_passives=3'
Write-Output 'INDONESIAN_COMPOUND_ARTICLE_NORMALIZATION_OK source=derivation-system target=sistem-derivasi'
Write-Output ("STRUCTURAL_TOTALS commands={0} environments={1} tokens={2} labels={3} references={4} citations={5} assets={6} imports={7} math={8} proof_blocks={9} localized_file_ids={10}" -f `
    $totals.commands, $totals.environments, $totals.localization_tokens,
    $totals.labels, $totals.references, $totals.citations, $totals.assets,
    $totals.imports, $totals.math_skeletons, $totals.proof_blocks,
    $totals.localized_file_ids)
Write-Output "PROOF_SYSTEMS_OVERVIEW_BATCH_REPLAY_OK files=$($units.Count) checks=$checks upstream=$expectedCommit next=OLP-0069"
