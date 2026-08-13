$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$localeRoot = $PSScriptRoot
$repoRoot = [IO.Path]::GetFullPath((Join-Path $localeRoot '..\..'))
$controlRoot = [IO.Path]::GetFullPath((Join-Path $repoRoot '..\_control'))
$manifestPath = Join-Path $controlRoot 'OPENLOGIC_CLOSURE_MANIFEST_20260812.csv'
$expectedCommit = '9620cc73f9c8e0ad003c514a5d3748f29611c4c0'
$relativeDir = 'content/first-order-logic/natural-deduction'

# TargetHash values are replaced only after both sole-writer batches reach a
# stable handoff and independent semantic dispositions are complete.
$units = @(
    [pscustomobject]@{ Id='OLP-0084'; Name='natural-deduction.tex'; SourceHash='8fa1e5a3e1211ce9c55e0ff66acbb8d5a6a9af360529d7775587a626fbe49b8e'; TargetHash='2827c36a18a38ce94e96c0e9d6c3cfd8707ac210cd4544578d13759fc725d92c' }
    [pscustomobject]@{ Id='OLP-0085'; Name='rules-and-proofs.tex'; SourceHash='0556326eefd6fbb957243d9f94969fd23adefb4af69f80419d4a2818d53088f0'; TargetHash='d070ac560767c37a11f545cac55ae2b79f105edcf7b18c0d7d377073874102ef' }
    [pscustomobject]@{ Id='OLP-0086'; Name='propositional-rules.tex'; SourceHash='c22d2603cc9c4a79d630a4bc00b817c57c07b000e5d4bc443815e13b4f4cb515'; TargetHash='7477693691999b64ef85a17103a0d38687658d7f6b8f884d9c0ec4b03d9745be' }
    [pscustomobject]@{ Id='OLP-0087'; Name='quantifier-rules.tex'; SourceHash='5d9c3a507fe1b79e4d376963b5e3efca4a3352cc7cef7d18255c61e60592f71b'; TargetHash='4ebf24041111ba2ef983b4ba86f482fb8a7a68ecfad8d19661d82f3d77a4740e' }
    [pscustomobject]@{ Id='OLP-0088'; Name='derivations.tex'; SourceHash='04cdbaa301a71243b78d880551ce2f8edbf6f059764eceacd5b8910f0459cb26'; TargetHash='b562ed11e296111e74d8603e78db2d9530730f933acaced59338064a5a480e53' }
    [pscustomobject]@{ Id='OLP-0089'; Name='proving-things.tex'; SourceHash='ff58b86389a21dbc6f240f49e62d5fca0bdb4d3ba54e0d364792cdcddd34724f'; TargetHash='069d99c8af43dc287db35c769f82c6e44e691275a9dc96456ec82e06389e2652' }
    [pscustomobject]@{ Id='OLP-0090'; Name='proving-things-quant.tex'; SourceHash='6f49b930a86f60a1cca318d70259378f7bc6b5ebb76f307665c4eb4363e8235f'; TargetHash='928d581265fc79e95633bc44151c1df984ef2ac4d06916c995b526fb539a230a' }
    [pscustomobject]@{ Id='OLP-0091'; Name='proof-theoretic-notions.tex'; SourceHash='7e05743251dd0c5071685193a98c28baea1c77b06836f11e3f3e3aa6a6bd9198'; TargetHash='bacfe229b38696e84d8debf870a167cab73b58b60c3ae3f0fa7fa9b760a6d1d9' }
    [pscustomobject]@{ Id='OLP-0092'; Name='provability-consistency.tex'; SourceHash='9d967013e14c7f911bf612ddab65b22a2e5f8d90f182926741c0bf7cab5076bc'; TargetHash='86d6278f81fdfc0a96cdbc0f1e92e90d32e92afee5ac618ee1b7aa2da4ca130c' }
    [pscustomobject]@{ Id='OLP-0093'; Name='provability-propositional.tex'; SourceHash='7be41cbf7877f1b7163f3cc9ad98867b4cf793b69f4a98e5734f731e3e802016'; TargetHash='477b33231262a1ba133603c32a8426f85536da5d9b619e8748a1c0cf0f4e1cd7' }
    [pscustomobject]@{ Id='OLP-0094'; Name='provability-quantifiers.tex'; SourceHash='c4a24bb64b2d02c75fcf5dcebe13d48c4684afd8f210da029ceefcb450990bf1'; TargetHash='b0c7c12f62c8d081213a896b2882ee2da171a092aab4d50cba52decddde9c86b' }
    [pscustomobject]@{ Id='OLP-0095'; Name='soundness.tex'; SourceHash='e470b5e3a94dd4445dcedc0bbb2d4bb9c5520a3f79ea754f37e4ae1501376e35'; TargetHash='f80b84001385431cce1809dddb5093ad3e69c37d6a89e58243c30e9f7dd57cfd' }
    [pscustomobject]@{ Id='OLP-0096'; Name='identity.tex'; SourceHash='d5df1d1bb3818a275e2439a584a3851036870182afde592fa6e8f80b55c00add'; TargetHash='d3292913ff525b924b0be718fb3a0c3f5215444ff1ed9e12bd0f650b18e3dc0c' }
    [pscustomobject]@{ Id='OLP-0097'; Name='soundness-identity.tex'; SourceHash='2544f37fa6d7a3d81b12c7e7309e1416680df9ee0d8d4e033084299370da0bc8'; TargetHash='c58ab126fc93a20849c2fd626e58ed7e25ca8a2004cabe2d58069b62f99c5143' }
)

$sourceDir = Join-Path $repoRoot ($relativeDir -replace '/', '\')
$targetDir = Join-Path $localeRoot ($relativeDir -replace '^content/', 'content/' -replace '/', '\')
$checks = 0
$totals = [ordered]@{ commands=0; environments=0; tokens=0; labels=0; references=0; citations=0; assets=0; imports=0; math=0; proof_blocks=0 }

function Get-Sha256([string]$Path) {
    (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
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
    # Path-scoped source corrections admitted by the independent source/target
    # audits. These substitutions affect only the exact frozen defects named
    # here; every other command, token, formula, and proof block remains under
    # strict ordered replay.
    if ($Name -ceq 'rules-and-proofs.tex') {
        $Text = $Text.Replace('other sequents, it must', 'other !!{sentence}s, it must')
    }
    if ($Name -ceq 'quantifier-rules.tex') {
        $Text = $Text.Replace(
            'even though $a$ in the above rule is a constant.',
            'even though $a$ in the above rule is !!a{constant}.')
        $Text = $Text.Replace(
            "The condition that an eigenvariable neither occur in the premises nor`n" +
            "in any assumption that is !!{undischarged} in the !!{derivation}s`n" +
            "leading to the premises for the \Intro{\lforall} or \Elim{\lexists}`n" +
            'inference is called the \emph{eigenvariable condition}.',
            "The occurrence restriction for an eigenvariable in the \Intro{\lforall}`n" +
            "or \Elim{\lexists} inference just stated is called the`n" +
            '\emph{eigenvariable condition}.')
    }
    if ($Name -ceq 'proving-things.tex') {
        $Text = $Text.Replace(
            '!!{sentence} in the end-sequent, while',
            '!!{sentence} that is the conclusion of !!{derivation}, while')
        $Text = $Text.Replace('!!{derive} $!B$ from~$!B$', '!!^{derive} $!B$ from~$!B$')
        $Text = $Text.Replace('sub-!!{formula}', 'sub!!{formula}')
        $Text = $Text.Replace('\RightLabel{\Intro{\lfalse}}', '\RightLabel{\Elim{\lnot}}')
    }
    if ($Name -ceq 'proving-things-quant.tex') {
        $Text = $Text.Replace(
            '$\lexists[x][!A(x)]$ or any assumptions that it depends on.',
            '$\lexists[x][\lnot !A(x)]$, the conclusion, or any undischarged assumptions on which it depends.')
        $Text = $Text.Replace('\Elim{\exists}', '\Elim{\lexists}')
    }
    if ($Name -ceq 'proof-theoretic-notions.tex') {
        $Text = $Text.Replace(
            'satisfaction of !!{sentence}s in !!{structure}s, but',
            'satisfaction of !!{sentence}s in \iftag{FOL}{!!{structure}}{!!{valuation}}, but')
    }
    if ($Name -ceq 'provability-consistency.tex') {
        $Text = $Text.Replace("  \RightLabel{\FalseCl}`n  \DischargeRule{\FalseCl}{1}", "  \DischargeRule{\FalseCl}{1}")
    }
    if ($Name -ceq 'provability-propositional.tex') {
        $Text = $Text.Replace(
            "Note that `$\Intro{\lif}`$ may, but does not have to, !!{discharge} the`n" +
            '    assumption~$!A$.',
            "Note that `$\Intro{\lif}`$ may !!{discharge} zero or more occurrences of`n" +
            "    the assumption~`$!A`$; in the !!a{derivation} on the right, it is`n" +
            '    applied without discharging an assumption.')
    }
    if ($Name -ceq 'soundness.tex') {
        # Indonesian requires the noun before the predicative/adjectival token.
        $Text = $Text.Replace('every !!{derivable} !!{sentence} is', 'every !!{sentence} that is !!{derivable} is')
        $Text = $Text.Replace(
            '!!a{structure}~\iftag{FOL}{$\Struct{M}$}{$\pAssign{v}$}',
            '\iftag{FOL}{!!a{structure}~$\Struct{M}$}{!!a{valuation}~$\pAssign{v}$}')
        $Text = $Text.Replace('\Elim{\forall}', '\Elim{\lforall}')
        $Text = $Text.Replace(
            '\Elim{\lor}, \Intro{\land}, \iftag{FOL}',
            '\Elim{\lor}, \Intro{\land}, \Elim{\lnot}, \iftag{FOL}')
    }
    if ($Name -ceq 'identity.tex') {
        $Text = $Text.Replace('\lforall[z]((', '\lforall[z][((')
        $Text = $Text.Replace('\eq[x][z])]]$', '\eq[x][z])]]]$')
    }
    $Text
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
    if ($unit.TargetHash -ceq 'PENDING') { throw "Target hash not frozen for $($unit.Id)" }
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

$phrases = @('This section','We will now','First suppose','The formula','Exercise.','Complete the proof','Give a derivation','If and only if','Soundness with','The rules for','Consider case','By induction hypothesis','The last inference','Let us show','Suppose that')
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

Write-Output ("STRUCTURAL_TOTALS commands={0} environments={1} tokens={2} labels={3} references={4} citations={5} assets={6} imports={7} math={8} proof_blocks={9}" -f $totals.commands,$totals.environments,$totals.tokens,$totals.labels,$totals.references,$totals.citations,$totals.assets,$totals.imports,$totals.math,$totals.proof_blocks)
Write-Output "NATURAL_DEDUCTION_BATCH_REPLAY_OK files=$($units.Count) checks=$checks upstream=$expectedCommit next=OLP-0098"
