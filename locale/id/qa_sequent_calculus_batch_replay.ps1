$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$localeRoot = $PSScriptRoot
$repoRoot = [IO.Path]::GetFullPath((Join-Path $localeRoot '..\..'))
$controlRoot = [IO.Path]::GetFullPath((Join-Path $repoRoot '..\_control'))
$manifestPath = Join-Path $controlRoot 'OPENLOGIC_CLOSURE_MANIFEST_20260812.csv'
$expectedCommit = '9620cc73f9c8e0ad003c514a5d3748f29611c4c0'
$relativeDir = 'content/first-order-logic/sequent-calculus'

$units = @(
    [pscustomobject]@{ Id='OLP-0069'; Name='sequent-calculus.tex'; SourceHash='8cbb6df83670a2586d10ef405c78ed4f75102f8d63903eef93e7ac2b8ea3b603'; TargetHash='72ecfceecadbfd2f7c27ae714acb11d861cfad85e1c5600857499d0cc0521437' }
    [pscustomobject]@{ Id='OLP-0070'; Name='rules-and-proofs.tex'; SourceHash='a598b850cb425035d0c7a01b88bb491502c840fc76c2bd3dbe7e2dda5487d706'; TargetHash='f6bb912f9390aa07557ee8278b86b7b938ce8657ad3daa0a6bc47e3730607847' }
    [pscustomobject]@{ Id='OLP-0071'; Name='propositional-rules.tex'; SourceHash='2a030e59a3a3156f61ff949e10a8a1470a0be80a419851fc56821aa458092ade'; TargetHash='2a7041c3ec0d0116cfb5cc7005f49a39be8efc77595584e91a194a14727f0dfd' }
    [pscustomobject]@{ Id='OLP-0072'; Name='quantifier-rules.tex'; SourceHash='254abc98503c7370e046c43f8fec7cf7b5e9909be2959b0f1c513bb278d85b78'; TargetHash='beeaaeb5de592e6cb3a47e003f99ea0b3bbb81f70f2f6d854b11e7a3abe7b645' }
    [pscustomobject]@{ Id='OLP-0073'; Name='structural-rules.tex'; SourceHash='ea1ca77eca03ec566cc900b2399e95002b4cfc07eb3549a3f19da9ee23a09793'; TargetHash='746bd301dd001de69368559c86b6228e191dd0a04b186c827e71edd80bdc9071' }
    [pscustomobject]@{ Id='OLP-0074'; Name='derivations.tex'; SourceHash='0d47d6984b609f00edfec9acc49c85d33ac001609f10e5e501cbd96f3a5f63dd'; TargetHash='d20a575a6e89ac8a71c7e008bbc842beb0c3134525a165a1a24f4f0bb327395e' }
    [pscustomobject]@{ Id='OLP-0075'; Name='proving-things.tex'; SourceHash='73fa9c16dcbd072ac535c251fa02fc78640b82381d57162817043a6ad578b18e'; TargetHash='897a12b7bc254b1324e1e7ec938f697e6643c91124540d7f0216ca22c1e7a466' }
    [pscustomobject]@{ Id='OLP-0076'; Name='proving-things-quant.tex'; SourceHash='9c249f76aa00ddc5b64b68179b052d7df7e7ffa69be413de20796d98bd80389d'; TargetHash='35a0d0d6b5aec91b1a2ccfe0bbe98059c00411a1baed4ccc86d15decf869c3cf' }
    [pscustomobject]@{ Id='OLP-0077'; Name='proof-theoretic-notions.tex'; SourceHash='aea2dd5d73394a3cd97b72ada3e7d21aac0113cc4d995b54196a5506b1fa5a81'; TargetHash='12837032db27238fc42e074d8bdf85b6ba6b93fb69aa3584cf76f33d3d1a3b27' }
    [pscustomobject]@{ Id='OLP-0078'; Name='provability-consistency.tex'; SourceHash='3e784d39f38d393203a7623b34e8fcad64e3299c102ee2ef96a812b5e6c8c229'; TargetHash='858f7f8d28106db6de7e18e9317efb8a6ccca0b48ebef5c1fd4926b6a14b3f9c' }
    [pscustomobject]@{ Id='OLP-0079'; Name='provability-propositional.tex'; SourceHash='13dd017159225b5fc9bcaa38c927fda407264d59c1305ebfd49329a85f5b9fa8'; TargetHash='5d42d1262f8ef255df39f99ae13b53bd71c5741a56b18037899ab48d5fd319da' }
    [pscustomobject]@{ Id='OLP-0080'; Name='provability-quantifiers.tex'; SourceHash='eb63f32c87bbdbef776a65a4c1da758fd5671e47e3c4171f224d3214b31aa48f'; TargetHash='7ef331eaa5b0fb31b7008c5f10309b84f807694321e359ffe7cec52fcd61556f' }
    [pscustomobject]@{ Id='OLP-0081'; Name='soundness.tex'; SourceHash='d9f6180bee35f29553144b6eca5a1eb1916e0262dcdc8c30f50193a53d8001fa'; TargetHash='427331d19c0c5c4eca75e4ba260a58ca26f53221713d0672bc2586eb86afcf6b' }
    [pscustomobject]@{ Id='OLP-0082'; Name='identity.tex'; SourceHash='f9abed3c3d8c2079b2be27fdcb551c8f1987d1b4db18ece56d4c9e1a7b066856'; TargetHash='f61e66e89e0b21beba942d90a08b46d26a700955dce5421f63972345c4148f37' }
    [pscustomobject]@{ Id='OLP-0083'; Name='soundness-identity.tex'; SourceHash='da0c929628dc2c252d9d48d2fff02439e26c7a984db958943aa6cd55bb4ffeb5'; TargetHash='33702681c0fbf2e7f3a1eaba470cffb87fc444d3a2dffa19f19354598301f56b' }
)

$sourceDir = Join-Path $repoRoot ($relativeDir -replace '/', '\')
$targetDir = Join-Path $localeRoot ($relativeDir -replace '^content/', 'content/' -replace '/', '\')
$checks = 0
$totals = [ordered]@{ commands=0; environments=0; tokens=0; labels=0; references=0; citations=0; assets=0; imports=0; math=0; proof_blocks=0 }

function Get-Sha256([string]$Path) {
    (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function Replace-Exact([string]$Text, [string]$Old, [string]$New, [int]$ExpectedCount, [string]$Name) {
    $actual = ([regex]::Matches($Text, [regex]::Escape($Old))).Count
    if ($actual -ne $ExpectedCount) { throw "$Name occurrence mismatch: expected=$ExpectedCount actual=$actual" }
    $Text.Replace($Old, $New)
}

function Get-BraceBalance([string]$Text) {
    $balance = 0
    for ($i = 0; $i -lt $Text.Length; $i++) {
        if ($Text[$i] -eq '%' -and ($i -eq 0 -or $Text[$i - 1] -ne '\')) {
            while ($i -lt $Text.Length -and $Text[$i] -ne "`n") { $i++ }
            continue
        }
        if ($Text[$i] -eq '{' -and ($i -eq 0 -or $Text[$i - 1] -ne '\')) { $balance++ }
        if ($Text[$i] -eq '}' -and ($i -eq 0 -or $Text[$i - 1] -ne '\')) { $balance-- }
        if ($balance -lt 0) { return $balance }
    }
    $balance
}

function Get-Sequence([string]$Text, [string]$Pattern) {
    @([regex]::Matches($Text, $Pattern, [Text.RegularExpressions.RegexOptions]::Singleline) |
        ForEach-Object { $_.Groups['value'].Value })
}

function Assert-Sequence([string]$Name, [object[]]$Expected, [object[]]$Actual) {
    if ($Expected.Count -ne $Actual.Count) { throw "$Name count mismatch: expected=$($Expected.Count) actual=$($Actual.Count)" }
    for ($i = 0; $i -lt $Expected.Count; $i++) {
        if ([string]$Expected[$i] -cne [string]$Actual[$i]) {
            throw "$Name mismatch at index $i`nEXPECTED: $($Expected[$i])`nACTUAL: $($Actual[$i])"
        }
    }
    $script:checks++
    Write-Output "PASS $Name count=$($Expected.Count)"
}

function Assert-RegexCount([string]$Name, [string]$Text, [string]$Pattern, [int]$Expected) {
    $actual = ([regex]::Matches($Text, $Pattern, [Text.RegularExpressions.RegexOptions]::Singleline)).Count
    if ($actual -ne $Expected) { throw "$Name count mismatch: expected=$Expected actual=$actual" }
    $script:checks++
    Write-Output "PASS $Name count=$actual"
}

function Replace-ProseArgument([string]$Text, [string]$Command) {
    $needle = "\$Command{"
    $builder = [Text.StringBuilder]::new()
    $i = 0
    while ($i -lt $Text.Length) {
        if (($i + $needle.Length -le $Text.Length) -and ($Text.Substring($i, $needle.Length) -ceq $needle)) {
            [void]$builder.Append("\$Command{<TEXT>}")
            $i += $needle.Length
            $depth = 1
            while ($i -lt $Text.Length -and $depth -gt 0) {
                if ($Text[$i] -eq '\' -and $i + 1 -lt $Text.Length) { $i += 2; continue }
                if ($Text[$i] -eq '{') { $depth++ } elseif ($Text[$i] -eq '}') { $depth-- }
                $i++
            }
            if ($depth -ne 0) { throw "Unbalanced \$Command argument" }
            continue
        }
        [void]$builder.Append($Text[$i]); $i++
    }
    $builder.ToString()
}

function Normalize-Math([string]$Text) {
    $x = Replace-ProseArgument -Text $Text -Command 'text'
    $x = Replace-ProseArgument -Text $x -Command 'intertext'
    # TeX's unbreakable-space marker is layout-only inside math; normalize it
    # together with ordinary whitespace while preserving every math command.
    [regex]::Replace($x, '[\s~]+', '')
}

function Get-MathSkeletons([string]$Text) {
    $items = [Collections.Generic.List[string]]::new()
    foreach ($m in [regex]::Matches($Text, '(?<!\\)\$(.*?)(?<!\\)\$', 'Singleline')) { $items.Add('INLINE:' + (Normalize-Math $m.Value)) }
    foreach ($m in [regex]::Matches($Text, '\\\[(.*?)\\\]', 'Singleline')) { $items.Add('DISPLAY:' + (Normalize-Math $m.Value)) }
    @($items)
}

function Get-ProofBlocks([string]$Text) {
    @([regex]::Matches($Text, '\\begin\{(?<environment>prooftree|oltableau|derivation)\}(?<body>.*?)\\end\{\k<environment>\}', 'Singleline') |
        ForEach-Object { $_.Groups['environment'].Value + ':' + [regex]::Replace($_.Groups['body'].Value, '\s+', '') })
}

function Get-CorrectedSourceForReplay([string]$Name, [string]$Text) {
    $x = $Text
    if ($Name -ceq 'proving-things.tex') {
        $old = @'
\RightLabel{\RightR{\Exchange}}
\UnaryInf$ !A, \lnot !A \lor !B \fCenter !B $
'@
        $new = @'
\RightLabel{\LeftR{\Exchange}}
\UnaryInf$ !A, \lnot !A \lor !B \fCenter !B $
'@
        $x = Replace-Exact $x $old $new 4 'antecedent-exchange-labels'
        # Restore the two missing negations in the source's description of
        # the De Morgan proof search. The displayed sequents already had them.
        $old = 'either the sequent $!A,' + "`n" + '\lnot !A \lor !B \Sequent \quad$ or the sequent $!B, \lnot !A' + "`n" + '\lor !B \Sequent \quad$.'
        $new = 'either the sequent $!A,' + "`n" + '\lnot !A \lor \lnot !B \Sequent \quad$ or the sequent $!B, \lnot !A' + "`n" + '\lor \lnot !B \Sequent \quad$.'
        $x = Replace-Exact $x $old $new 1 'missing-De-Morgan-negations'
        $x = Replace-Exact $x 'one of these two !!{derivation}s:' 'one of these two partial proof-search trees:' 1 'partial-trees-not-derivations'
    }
    if ($Name -ceq 'provability-propositional.tex') {
        $old = @'
      \Axiom$!A \fCenter !A$
      \Axiom$!B \fCenter !B$
      \RightLabel{\RightR{\land}}
      \BinaryInf$!A, !B \fCenter !A \land !B$
'@
        $new = @'
      \Axiom$!A \fCenter !A$
      \RightLabel{\LeftR{\Weakening}}
      \UnaryInf$!B, !A \fCenter !A$
      \RightLabel{\LeftR{\Exchange}}
      \UnaryInf$!A, !B \fCenter !A$
      \Axiom$!B \fCenter !B$
      \RightLabel{\LeftR{\Weakening}}
      \UnaryInf$!A, !B \fCenter !B$
      \RightLabel{\RightR{\land}}
      \BinaryInf$!A, !B \fCenter !A \land !B$
'@
        $x = Replace-Exact $x $old $new 1 'same-context-right-conjunction-proof'
    }
    if ($Name -ceq 'soundness.tex') {
        $x = Replace-Exact $x '!!^a{derivation} system' 'a system !!{derivation}' 1 'Indonesian-system-order-capital'
        $x = Replace-Exact $x '!!a{derivation} system' 'a system !!{derivation}' 1 'Indonesian-system-order-article'
        $x = Replace-Exact $x '!!{derivation} system' 'system !!{derivation}' 3 'Indonesian-system-order'
        $x = Replace-Exact $x 'arbitrary, $\Gamma \Sequent \Delta$ is valid.' 'arbitrary, $!A \land !B, \Gamma \Sequent \Delta$ is valid.' 1 'left-conjunction-conclusion'
        $x = Replace-Exact $x '$\Pi \setminus \Lambda$' '$\Pi \Sequent \Lambda$' 1 'cut-right-premise-sequent'
    }
    $x
}

function Remove-NonReaderSurface([string]$Text) {
    $x = [regex]::Replace($Text, '(?m)(?<!\\)%.*$', '')
    $x = [regex]::Replace($x, '\\begin\{(?:prooftree|oltableau|derivation)\}.*?\\end\{(?:prooftree|oltableau|derivation)\}', '', 'Singleline')
    $x = [regex]::Replace($x, '(?<!\\)\$.*?(?<!\\)\$', '', 'Singleline')
    $x = [regex]::Replace($x, '\\\[.*?\\\]', '', 'Singleline')
    $x = [regex]::Replace($x, '!!(?:\^)?(?:a|A)?\{[^{}]+\}(?:s|d)?', '')
    $x
}

& git -C $repoRoot merge-base --is-ancestor $expectedCommit HEAD
if ($LASTEXITCODE -ne 0) { throw "Frozen source commit $expectedCommit is not an ancestor of HEAD" }
if (-not (Test-Path -LiteralPath $manifestPath)) { throw "Missing manifest $manifestPath" }
$manifest = Import-Csv -LiteralPath $manifestPath
$patterns = [ordered]@{
    commands='(?<value>\\[A-Za-z@]+|\\.)'
    environments='(?<value>\\(?:begin|end)\{[^{}]+\})'
    tokens='(?<value>!!(?:\^)?(?:a|A)?\{[^{}]+\}(?:s|d)?)'
    labels='(?<value>\\ollabel\{[^{}]+\})'
    references='(?<value>\\(?:olref|Olref)(?:\[[^\]]*\]){0,3}\{[^{}]+\})'
    citations='(?<value>\\cite[a-zA-Z]*\{[^{}]+\})'
    assets='(?<value>\\olasset(?:\[[^\]]*\])?\{[^{}]+\})'
    imports='(?<value>\\olimport\*?(?:\[[^\]]*\])?\{[^{}]+\})'
}

$allTarget = [Collections.Generic.List[string]]::new()
foreach ($unit in $units) {
    $sourceRelative = "$relativeDir/$($unit.Name)"
    $targetRelative = "locale/id/$relativeDir/$($unit.Name)"
    $sourcePath = Join-Path $sourceDir $unit.Name
    $targetPath = Join-Path $targetDir $unit.Name
    $rows = @($manifest | Where-Object { $_.closure_id -ceq $unit.Id })
    if ($rows.Count -ne 1) { throw "Manifest row count for $($unit.Id): $($rows.Count)" }
    $row = $rows[0]
    if ($row.source_commit -cne $expectedCommit -or $row.source_path -cne $sourceRelative -or
        $row.source_sha256.ToLowerInvariant() -cne $unit.SourceHash -or $row.target_path -cne $targetRelative) {
        throw "Manifest binding mismatch for $($unit.Id)"
    }
    $checks++; Write-Output "PASS $($unit.Id)/manifest-binding"
    if ((Get-Sha256 $sourcePath) -cne $unit.SourceHash) { throw "Source hash mismatch $($unit.Id)" }
    if ((Get-Sha256 $targetPath) -cne $unit.TargetHash) { throw "Target hash mismatch $($unit.Id)" }
    $checks += 2
    Write-Output "PASS $($unit.Id)/source-hash $($unit.SourceHash)"
    Write-Output "PASS $($unit.Id)/target-hash $($unit.TargetHash)"

    $source = [IO.File]::ReadAllText($sourcePath).Replace("`r`n", "`n")
    $target = [IO.File]::ReadAllText($targetPath).Replace("`r`n", "`n")
    $corrected = Get-CorrectedSourceForReplay $unit.Name $source
    $allTarget.Add($target)
    if ((Get-BraceBalance $source) -ne 0 -or (Get-BraceBalance $target) -ne 0) { throw "Brace balance failed $($unit.Id)" }
    $checks++; Write-Output "PASS $($unit.Id)/brace-balance"

    foreach ($entry in $patterns.GetEnumerator()) {
        $expected = @(Get-Sequence $corrected $entry.Value)
        $actual = @(Get-Sequence $target $entry.Value)
        if ($entry.Key -ceq 'tokens') {
            # Indonesian has no article or inflectional plural suffix. Bind
            # the ordered token concepts while allowing those English-only
            # surface markers to disappear.
            $expected = @($expected | ForEach-Object { if ($_ -match '\{(?<key>[^{}]+)\}') { [regex]::Replace($Matches.key, '\s+', ' ') } else { $_ } })
            $actual = @($actual | ForEach-Object { if ($_ -match '\{(?<key>[^{}]+)\}') { [regex]::Replace($Matches.key, '\s+', ' ') } else { $_ } })
        }
        Assert-Sequence "$($unit.Id)/$($entry.Key)" $expected $actual
        $totals[$entry.Key] += $expected.Count
    }

    $sourceFileIds = @(Get-Sequence $source '(?<value>\\olfileid\{[^{}]+\}\{[^{}]+\}\{[^{}]+\})')
    $expectedFileIds = @($sourceFileIds | ForEach-Object { $_ -replace '^\\olfileid', '\olfileid[id]' })
    $targetFileIds = @(Get-Sequence $target '(?<value>\\olfileid\[id\]\{[^{}]+\}\{[^{}]+\}\{[^{}]+\})')
    Assert-Sequence "$($unit.Id)/localized-file-ids" $expectedFileIds $targetFileIds

    $sourceChapterIds = @(Get-Sequence $source '\\olchapter\{(?<value>[^{}]+\}\{[^{}]+)\}\{')
    $targetChapterIds = @(Get-Sequence $target '\\olchapter\[id\]\{(?<value>[^{}]+\}\{[^{}]+)\}\{')
    Assert-Sequence "$($unit.Id)/localized-chapter-ids" $sourceChapterIds $targetChapterIds

    $sourceMath = @(Get-MathSkeletons $corrected); $targetMath = @(Get-MathSkeletons $target)
    Assert-Sequence "$($unit.Id)/math-skeletons" $sourceMath $targetMath
    $totals.math += $sourceMath.Count
    $sourceProofs = @(Get-ProofBlocks $corrected); $targetProofs = @(Get-ProofBlocks $target)
    Assert-Sequence "$($unit.Id)/proof-blocks" $sourceProofs $targetProofs
    $totals.proof_blocks += $sourceProofs.Count
}

$joinedTarget = $allTarget -join "`n"
Assert-RegexCount 'correction/antecedent-exchange-labels' $joinedTarget '\\RightLabel\{\\LeftR\{\\Exchange\}\}\s*\\UnaryInf\$ !A, \\lnot !A \\lor !B \\fCenter !B \$' 4
Assert-RegexCount 'correction/De-Morgan-negations' $joinedTarget '\\lnot !A \\lor \\lnot !B \\Sequent \\quad\$ atau sekuen \$!B, \\lnot !A\s*\\lor \\lnot !B \\Sequent \\quad\$' 1
Assert-RegexCount 'correction/partial-proof-search-trees' $joinedTarget 'pohon pencarian pembuktian parsial berikut' 1
Assert-RegexCount 'correction/propositional-shared-left-context' $joinedTarget '\\UnaryInf\$!A, !B \\fCenter !A\$.*?\\UnaryInf\$!A, !B \\fCenter !B\$.*?\\RightLabel\{\\RightR\{\\land\}\}' 1
Assert-RegexCount 'correction/soundness-left-conjunction-conclusion' $joinedTarget '\$!A \\land !B, \\Gamma \\Sequent \\Delta\$ valid' 1
Assert-RegexCount 'correction/soundness-cut-right-premise' $joinedTarget 'memenuhi \$\\Pi \\Sequent \\Lambda\$' 1
Assert-RegexCount 'correction/editorial-sequent-not-natural-deduction' $joinedTarget 'relasi keterbuktian dan konsistensi\s+untuk kalkulus sekuen' 1

$phrases = @('This section','We will now','First suppose','The sequent','Exercise.','Complete the proof','Give a','If and only if','Soundness with','Initial sequents','The rules for','Consider case','By induction hypothesis','The last inference')
foreach ($unit in $units) {
    $targetPath = Join-Path $targetDir $unit.Name
    $reader = Remove-NonReaderSurface ([IO.File]::ReadAllText($targetPath))
    foreach ($phrase in $phrases) {
        if ($reader.IndexOf($phrase, [StringComparison]::OrdinalIgnoreCase) -ge 0) {
            throw "Reader-facing English residue in $($unit.Id): $phrase"
        }
    }
}
$checks++; Write-Output 'PASS batch/untranslated-reader-facing-English'

Write-Output 'SOURCE_CORRECTIONS_OK classes=7 exact_occurrences=12'
Write-Output ("STRUCTURAL_TOTALS commands={0} environments={1} tokens={2} labels={3} references={4} citations={5} assets={6} imports={7} math={8} proof_blocks={9}" -f $totals.commands,$totals.environments,$totals.tokens,$totals.labels,$totals.references,$totals.citations,$totals.assets,$totals.imports,$totals.math,$totals.proof_blocks)
Write-Output "SEQUENT_CALCULUS_BATCH_REPLAY_OK files=$($units.Count) checks=$checks upstream=$expectedCommit next=OLP-0084"
