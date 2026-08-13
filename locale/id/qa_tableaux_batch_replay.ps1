$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$localeRoot = $PSScriptRoot
$repoRoot = [IO.Path]::GetFullPath((Join-Path $localeRoot '..\..'))
$controlRoot = [IO.Path]::GetFullPath((Join-Path $repoRoot '..\_control'))
$manifestPath = Join-Path $controlRoot 'OPENLOGIC_CLOSURE_MANIFEST_20260812.csv'
$expectedCommit = '9620cc73f9c8e0ad003c514a5d3748f29611c4c0'
$first = 98
$last = 111
$checks = 0

function Get-Sha256([string]$Path) {
    (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function Get-TextDigest([string[]]$Items) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        $text = $Items -join [char]0x241e
        ([BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($text))).Replace('-', '').ToLowerInvariant())
    } finally { $sha.Dispose() }
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
        ForEach-Object { $_.Value })
}

function Get-MathSkeletons([string]$Text) {
    $items = [Collections.Generic.List[string]]::new()
    foreach ($m in [regex]::Matches($Text, '(?<!\\)\$(.*?)(?<!\\)\$', 'Singleline')) {
        $items.Add('INLINE:' + [regex]::Replace($m.Value, '\s+', ''))
    }
    foreach ($m in [regex]::Matches($Text, '\\\[(.*?)\\\]', 'Singleline')) {
        $items.Add('DISPLAY:' + [regex]::Replace($m.Value, '\s+', ''))
    }
    @($items)
}

function Get-FormalBlocks([string]$Text) {
    @([regex]::Matches($Text, '\\begin\{(?<environment>prooftree|oltableau|tableau)\}(?<body>.*?)\\end\{\k<environment>\}', 'Singleline') |
        ForEach-Object { $_.Groups['environment'].Value + ':' + [regex]::Replace($_.Groups['body'].Value, '\s+', '') })
}

function Assert-Exact([bool]$Condition, [string]$Name) {
    if (-not $Condition) { throw "FAIL $Name" }
    $script:checks++
    Write-Output "PASS $Name"
}

& git -C $repoRoot merge-base --is-ancestor $expectedCommit HEAD
Assert-Exact ($LASTEXITCODE -eq 0) 'frozen-source-ancestor'
Assert-Exact (Test-Path -LiteralPath $manifestPath) 'closure-manifest-present'

$manifest = Import-Csv -LiteralPath $manifestPath
$units = @($manifest | Where-Object {
    [int]$_.stable_order -ge $first -and [int]$_.stable_order -le $last
} | Sort-Object { [int]$_.stable_order })
Assert-Exact ($units.Count -eq 14) 'closure-count-14'

$patterns = [ordered]@{
    environments = '\\(?:begin|end)\{[^{}]+\}'
    labels       = '\\ollabel\{[^{}]+\}'
    references   = '\\(?:olref|Olref)(?:\[[^\]]*\]){0,3}\{[^{}]+\}'
    citations    = '\\cite[a-zA-Z]*\{[^{}]+\}'
    assets       = '\\olasset(?:\[[^\]]*\])?\{[^{}]+\}'
    imports      = '\\olimport\*?(?:\[[^\]]*\])?\{[^{}]+\}'
}
$totals = [ordered]@{ environments=0; labels=0; references=0; citations=0; assets=0; imports=0; math=0; formal_blocks=0 }

foreach ($unit in $units) {
    $sourcePath = Join-Path $repoRoot ($unit.source_path -replace '/', '\')
    $targetPath = Join-Path $repoRoot ($unit.target_path -replace '/', '\')
    Assert-Exact (Test-Path -LiteralPath $sourcePath) "$($unit.closure_id)/source-present"
    Assert-Exact (Test-Path -LiteralPath $targetPath) "$($unit.closure_id)/target-present"
    Assert-Exact ((Get-Sha256 $sourcePath) -ceq $unit.source_sha256.ToLowerInvariant()) "$($unit.closure_id)/source-hash"
    if (-not [string]::IsNullOrWhiteSpace($unit.target_sha256)) {
        Assert-Exact ((Get-Sha256 $targetPath) -ceq $unit.target_sha256.ToLowerInvariant()) "$($unit.closure_id)/target-hash"
    }

    $source = [IO.File]::ReadAllText($sourcePath).Replace("`r`n", "`n")
    $target = [IO.File]::ReadAllText($targetPath).Replace("`r`n", "`n")
    Assert-Exact ((Get-BraceBalance $source) -eq 0 -and (Get-BraceBalance $target) -eq 0) "$($unit.closure_id)/brace-balance"

    foreach ($entry in $patterns.GetEnumerator()) {
        $s = @(Get-Sequence $source $entry.Value)
        $t = @(Get-Sequence $target $entry.Value)
        Assert-Exact ($s.Count -eq $t.Count -and (Get-TextDigest $s) -ceq (Get-TextDigest $t)) "$($unit.closure_id)/$($entry.Key)-sequence"
        $totals[$entry.Key] += $s.Count
    }

    $sourceFileIds = @(Get-Sequence $source '\\olfileid\{[^{}]+\}\{[^{}]+\}\{[^{}]+\}')
    $targetFileIds = @(Get-Sequence $target '\\olfileid\[id\]\{[^{}]+\}\{[^{}]+\}\{[^{}]+\}')
    Assert-Exact ($sourceFileIds.Count -eq $targetFileIds.Count) "$($unit.closure_id)/localized-file-id-count"
    $sourceChapterIds = @(Get-Sequence $source '\\olchapter\{[^{}]+\}\{[^{}]+\}\{')
    $targetChapterIds = @(Get-Sequence $target '\\olchapter\[id\]\{[^{}]+\}\{[^{}]+\}\{')
    Assert-Exact ($sourceChapterIds.Count -eq $targetChapterIds.Count) "$($unit.closure_id)/localized-chapter-id-count"

    $sourceMath = @(Get-MathSkeletons $source)
    $targetMath = @(Get-MathSkeletons $target)
    # The only count delta is OLP-0105's repair of the malformed source set
    # expression D_1,...,D_m \subseteq Gamma into a single well-typed math span.
    if ($unit.closure_id -ceq 'OLP-0105') {
        Assert-Exact ($sourceMath.Count -eq ($targetMath.Count + 1)) "$($unit.closure_id)/documented-math-count-delta"
    } else {
        Assert-Exact ($sourceMath.Count -eq $targetMath.Count) "$($unit.closure_id)/math-count"
    }
    $totals.math += $targetMath.Count
    $sourceFormal = @(Get-FormalBlocks $source)
    $targetFormal = @(Get-FormalBlocks $target)
    Assert-Exact ($sourceFormal.Count -eq $targetFormal.Count) "$($unit.closure_id)/formal-block-count"
    $totals.formal_blocks += $targetFormal.Count
}

$targetRoot = Join-Path $localeRoot 'content\first-order-logic\tableaux'
$all = (Get-ChildItem -LiteralPath $targetRoot -Filter '*.tex' | ForEach-Object { [IO.File]::ReadAllText($_.FullName) }) -join "`n"
Assert-Exact (-not [regex]::IsMatch($all, '\\ol(?:fileid|chapter)(?!\[id\])')) 'all-locale-identifiers-id'

# Positive and rejected-form assertions bind the admitted source repairs. The
# independent paragraph replay is recorded separately; these assertions make
# every mathematical correction machine-visible and path-specific.
$assertions = @(
    @('tableaux.tex', 'tableau sebagai sistem pembuktian', 'natural deduction sebagai sistem pembuktian'),
    @('quantifier-rules.tex', '\TRule{\True}{\lforall}', '\TRule{\True}{\forall}'),
    @('derivations.tex', '\sFmla{\True}{!A}', '\sFmla{!A}'),
    @('proving-things.tex', '\sFmla{\True}{!A \lor !B}, \sFmla{\True}{\lnot !B}', '\sFmla{\True}{!A \lor !B, \lnot !B}'),
    @('proving-things-quant.tex', 'baris $1$ dan~$4$', 'baris $1$ dan~$3$'),
    @('proof-theoretic-notions.tex', '\{!D_1, \dots, !D_m\} \subseteq \Gamma', '$!D_1$, \dots, $!D_m \subseteq \Gamma$'),
    @('provability-consistency.tex', '!C_1, \dots, !C_m', '!C_1, \dots, !C_n'),
    @('provability-propositional.tex', '\sFmla{\True}{\formula{A}}', '\sFmla{\True{\formula{A}}}'),
    @('provability-quantifiers.tex', '\sFmla{\True}{\lforall[x][!A(x)]}$:', '\sFmla{\True}{\lforall[x][!A(x)]}, $ adalah:'),
    @('soundness.tex', '\sFmla{\True}{\lforall[x][!A(x)]}', '\sFmla{\True}{\lforall[x][!B(x)]}'),
    @('identity.tex', '\eq[s_1][s_2]', '\eq[t_1][t_2]$ (yakni baris~$2$)'),
    @('soundness-identity.tex', '\sFmla{\True}{!A(t_2)}', '\sFmla{S}{!A(t_2)}')
)
foreach ($a in $assertions) {
    $text = [IO.File]::ReadAllText((Join-Path $targetRoot $a[0]))
    Assert-Exact ($text.Contains($a[1])) "correction-positive/$($a[0])"
    Assert-Exact (-not $text.Contains($a[2])) "correction-rejected/$($a[0])"
}

Write-Output ("STRUCTURAL_TOTALS environments={0} labels={1} references={2} citations={3} assets={4} imports={5} math={6} formal_blocks={7} correction_assertions={8}" -f $totals.environments,$totals.labels,$totals.references,$totals.citations,$totals.assets,$totals.imports,$totals.math,$totals.formal_blocks,($assertions.Count * 2))
Write-Output "TABLEAUX_BATCH_REPLAY_OK files=$($units.Count) checks=$checks upstream=$expectedCommit next=OLP-0112"
