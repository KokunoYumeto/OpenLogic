$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$localeRoot = $PSScriptRoot
$repoRoot = [IO.Path]::GetFullPath((Join-Path $localeRoot '..\..'))
$controlRoot = [IO.Path]::GetFullPath((Join-Path $repoRoot '..\_control'))
$manifestPath = Join-Path $controlRoot 'OPENLOGIC_CLOSURE_MANIFEST_20260812.csv'
$expectedCommit = '9620cc73f9c8e0ad003c514a5d3748f29611c4c0'

# SourceHash binds the normalized worktree bytes recorded in the complete
# closure manifest. SourceBlob binds the immutable Git object at the frozen
# upstream commit. TargetHash freezes the live post-review Indonesian bytes.
$units = @(
    [pscustomobject]@{ Id='OLP-0149'; Path='content/first-order-logic/syntax-and-semantics/syntax.tex';                SourceBlob='26a53094f9884a8442f11a57571e9e59b7145386'; SourceHash='75c0e56b3d2f9557e39b9006855f371e6c8f04e8ef9817affd70a793613930ab'; TargetHash='3a1ddcbdb6a08b225561818d7d61ee0853cac79a96de7ee10eaf07950cf2c24b' }
    [pscustomobject]@{ Id='OLP-0150'; Path='content/first-order-logic/syntax-and-semantics/intro-syntax.tex';          SourceBlob='948a77a1d2c7c7c944a7032850481a1ac7862029'; SourceHash='ba7dcce5f1e3340374ff693a1c22c5bf4ccb0c2709cd8c6d50474d4982f7cdfc'; TargetHash='f438ff0f7e92c69dda03862c7bce61f5b71d0cc62fd7143bca6c387a2a036643' }
    [pscustomobject]@{ Id='OLP-0151'; Path='content/first-order-logic/syntax-and-semantics/first-order-languages.tex'; SourceBlob='35b5b1b562963cf6a36d58eeaa0d3c5376137001'; SourceHash='582ea4b3b243fe2ee4eb627630172f77f014d4f7d7c93cd13fdb2bb70844c447'; TargetHash='59ff47a62429b9a6d07104553b0ceb95a2309be466e24a6b9769364f86a0a7a7' }
    [pscustomobject]@{ Id='OLP-0152'; Path='content/first-order-logic/syntax-and-semantics/terms-formulas.tex';        SourceBlob='4e417155eb1b810453718bd957d96842c783b1ed'; SourceHash='0b607ce2324ca66b23b164684f4f35b127107b903bbbd567eb25e94c2ce70210'; TargetHash='56f2e81f01718dc932dc7ba8557b5743b6cc79ae3e12bf032ac8aace71e5ccc2' }
    [pscustomobject]@{ Id='OLP-0153'; Path='content/first-order-logic/syntax-and-semantics/unique-readability.tex';    SourceBlob='d9ecd7279fbe9254217503b7ca6d136661cafe79'; SourceHash='f2ad2961312808ef6c8dedc884c9f8e00a2be9ef993cfb7be748a9d253d84e66'; TargetHash='5bffef343bfb7d2c56e36af080d2ee3e0aaa4ea87fa61ce958ebb44da0aeb9a3' }
    [pscustomobject]@{ Id='OLP-0154'; Path='content/first-order-logic/syntax-and-semantics/main-operator.tex';         SourceBlob='a95d176157271c9cb68b61e42a1e2a23fca8bc30'; SourceHash='1bc4cc76cc670fdb1069ca53312d13dfcf2ea8444adbb3d9ef4b8d31a5da41fc'; TargetHash='9f302914484f2c2d59a093a507dffd2f5e502891acbfe312ec015c1b534acb8c' }
    [pscustomobject]@{ Id='OLP-0155'; Path='content/first-order-logic/syntax-and-semantics/subformulas.tex';          SourceBlob='ff11944f28c23dbbfc68531c3eaaff330b068f7c'; SourceHash='4c43825e4c236e55d25092ff1f5b68ed38a3f1e9ae8ed12fc2e14f3a03fc6c77'; TargetHash='94efc916c1448422d783ad000d60b28e418d0391c6957956a748659fb0e0e5f7' }
    [pscustomobject]@{ Id='OLP-0156'; Path='content/first-order-logic/syntax-and-semantics/formation-sequences.tex';   SourceBlob='64cc604fb5c222c25c3ceaa4bcfe7ba977dde6e8'; SourceHash='dc1735bb077f5086c6fd6e2f968591415a9cba90b65bc0a3d412742cc62bc6ff'; TargetHash='7c19a366726bc2944dc1d8458eddfc2f9ac432e71a9d8a837e03e1703834c972' }
    [pscustomobject]@{ Id='OLP-0157'; Path='content/first-order-logic/syntax-and-semantics/free-vars-sentences.tex';  SourceBlob='04b436c68f8d0965f763a39fd2dab3ea4494429c'; SourceHash='ea6bea6e587867742143e68dd69a2674fc1544ffaae27236ba1f517fe516bf1f'; TargetHash='1203b1fa75bba061ac7e92e496603bbb1b08c5c26182a0130cedc015f0c7f2ae' }
    [pscustomobject]@{ Id='OLP-0158'; Path='content/first-order-logic/syntax-and-semantics/substitution.tex';          SourceBlob='6a197db01cc1d8f9c87b5ce1ea0b9a64f6053f6b'; SourceHash='19393c28f5f036da9c43ce10bfb5f1b2f330dca8cb2ad950d98eab5b1b7e83b2'; TargetHash='474eda8d54af76d7bb262ea6211d114a0c2b17897b4629c42b050922ec5fcaf3' }
)

$checks = 0
$sourceCorrectionClasses = 0
$sourceCorrectionOccurrences = 0
$targetCorrectionAssertions = 0
$targetReviewAssertions = 0
$totals = [ordered]@{
    commands = 0
    environments = 0
    semantic_tokens = 0
    labels = 0
    references = 0
    citations = 0
    assets = 0
    imports = 0
    tagged_items = 0
    tag_conditionals = 0
    math_skeletons = 0
    math_environments = 0
    localized_file_ids = 0
    chapter_ids = 0
}

function Normalize-Newlines([string]$Text) {
    return ($Text -replace "`r`n", "`n" -replace "`r", "`n")
}

function Get-Sha256([string]$Path) {
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function Get-BytesSha256([byte[]]$Bytes) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash($Bytes))).Replace('-', '').ToLowerInvariant() }
    finally { $sha.Dispose() }
}

function Get-TextDigest([string[]]$Items) {
    return Get-BytesSha256 ([Text.Encoding]::UTF8.GetBytes(($Items -join "`n")))
}

function Invoke-GitBytes([string[]]$Arguments) {
    $start = [Diagnostics.ProcessStartInfo]::new()
    $start.FileName = 'git'
    $start.WorkingDirectory = $repoRoot
    $start.UseShellExecute = $false
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    foreach ($argument in $Arguments) { [void]$start.ArgumentList.Add($argument) }
    $process = [Diagnostics.Process]::Start($start)
    $memory = [IO.MemoryStream]::new()
    try {
        $copyTask = $process.StandardOutput.BaseStream.CopyToAsync($memory)
        $errorTask = $process.StandardError.ReadToEndAsync()
        [void]$copyTask.GetAwaiter().GetResult()
        $errorText = $errorTask.GetAwaiter().GetResult()
        $process.WaitForExit()
        if ($process.ExitCode -ne 0) { throw "git $($Arguments -join ' ') failed: $errorText" }
        return ,$memory.ToArray()
    } finally {
        $memory.Dispose()
        $process.Dispose()
    }
}

function Assert-Exact([bool]$Condition, [string]$Name, [string]$Detail = '') {
    if (-not $Condition) { throw "FAIL $Name $Detail" }
    $script:checks++
    if ($Detail) { Write-Output "PASS $Name $Detail" } else { Write-Output "PASS $Name" }
}

function Assert-Sequence([string]$Name, [object[]]$Expected, [object[]]$Actual) {
    if ($Expected.Count -ne $Actual.Count) {
        throw "$Name count mismatch: source=$($Expected.Count) target=$($Actual.Count)"
    }
    for ($index = 0; $index -lt $Expected.Count; $index++) {
        if ([string]$Expected[$index] -cne [string]$Actual[$index]) {
            throw "$Name mismatch at index $index`nSOURCE: $($Expected[$index])`nTARGET: $($Actual[$index])"
        }
    }
    $script:checks++
    Write-Output "PASS $Name count=$($Expected.Count)"
}

function Get-BraceBalance([string]$Text) {
    $balance = 0
    $inComment = $false
    for ($index = 0; $index -lt $Text.Length; $index++) {
        $character = $Text[$index]
        if ($inComment) { if ($character -eq "`n") { $inComment = $false }; continue }
        $slashes = 0
        for ($left = $index - 1; $left -ge 0 -and $Text[$left] -eq '\'; $left--) { $slashes++ }
        $escaped = (($slashes % 2) -eq 1)
        if ($character -eq '%' -and -not $escaped) { $inComment = $true; continue }
        if ($escaped) { continue }
        if ($character -eq '{') { $balance++ } elseif ($character -eq '}') { $balance-- }
        if ($balance -lt 0) { return $balance }
    }
    return $balance
}

function Remove-TexComments([string]$Text) {
    $builder = [Text.StringBuilder]::new()
    foreach ($line in ((Normalize-Newlines $Text) -split "`n", 0, 'SimpleMatch')) {
        $cut = -1
        for ($index = 0; $index -lt $line.Length; $index++) {
            if ($line[$index] -ne '%') { continue }
            $slashes = 0
            for ($left = $index - 1; $left -ge 0 -and $line[$left] -eq '\'; $left--) { $slashes++ }
            if (($slashes % 2) -eq 0) { $cut = $index; break }
        }
        if ($cut -ge 0) { [void]$builder.Append($line.Substring(0, $cut)) }
        else { [void]$builder.Append($line) }
        [void]$builder.Append("`n")
    }
    return $builder.ToString()
}

function Get-Sequence([string]$Text, [string]$Pattern, [string]$Group = 'value') {
    return @([regex]::Matches($Text, $Pattern, 'Singleline') | ForEach-Object { $_.Groups[$Group].Value })
}

function Replace-Exact([string]$Text, [string]$Old, [string]$New, [int]$ExpectedCount, [string]$Name) {
    $actual = ([regex]::Matches($Text, [regex]::Escape($Old))).Count
    if ($actual -ne $ExpectedCount) { throw "$Name source occurrence mismatch expected=$ExpectedCount actual=$actual" }
    return $Text.Replace($Old, $New)
}

function Get-CorrectedSourceForReplay([string]$Path, [string]$Text) {
    $result = Normalize-Newlines $Text
    switch ($Path) {
        'content/first-order-logic/syntax-and-semantics/first-order-languages.tex' {
            $result = Replace-Exact $result `
                '\iftag{defTrue}{\ycomma !!{truth}~$\ltrue$}}{}.' `
                '\iftag{defTrue}{\ycomma !!{truth}~$\ltrue$}{}.}{}' 1 `
                'first-order-languages/nested-iftag-closure'
        }
        'content/first-order-logic/syntax-and-semantics/terms-formulas.tex' {
            $result = Replace-Exact $result `
                '$\lnot !A \lor !B)$' `
                '$\lnot !A \lor !B$' 1 'terms-formulas/unmatched-parenthesis'
        }
        'content/first-order-logic/syntax-and-semantics/main-operator.tex' {
            $result = Replace-Exact $result '$(!A \land !B$)' '$(!A \land !B)$' 1 `
                'main-operator/conjunction-parenthesis-math-mode'
            $result = Replace-Exact $result '$(!A \lor !B$)' '$(!A \lor !B)$' 1 `
                'main-operator/disjunction-parenthesis-math-mode'
            $result = Replace-Exact $result '$(!A \lif !B$)' '$(!A \lif !B)$' 1 `
                'main-operator/conditional-parenthesis-math-mode'
        }
        'content/first-order-logic/syntax-and-semantics/formation-sequences.tex' {
            $result = Replace-Exact $result `
                '$m_0,\dotsc,m_k < i$ such that $t_i \ident f(t_{m_0},\dotsc,t_{m_k})$.' `
                '$m_1,\dotsc,m_k < i$ such that $t_i \ident f(t_{m_1},\dotsc,t_{m_k})$.' 1 `
                'formation-sequences/k-ary-indices'
            $result = Replace-Exact $result `
                'formation sequence of length $m < n$' `
                'formation sequence with final index $m < n$' 1 `
                'formation-sequences/induction-measure'
            $result = Replace-Exact $result '\Frm[L_0]' '\Frm[L]' 2 `
                'formation-sequences/language-subscript'
            $result = Replace-Exact $result `
                '$!A \equiv (!A_j \land !A_k)$' `
                '$!A \ident (!A_j \land !A_k)$' 1 `
                'formation-sequences/syntactic-identity'
            $result = Replace-Exact $result 'sub-!!{formula}' '!!{subformula}' 1 `
                'formation-sequences/indonesian-subformula-token'
        }
    }
    return $result
}

function Get-CorrectedSourceForTokenReplay([string]$Path, [string]$Text) {
    $result = $Text
    switch ($Path) {
        'content/first-order-logic/syntax-and-semantics/unique-readability.tex' {
            $result = Replace-Exact $result ("!!{main" + "`n" + '  operator}') '!!{main operator}' 1 `
                'unique-readability/semantic-token-line-wrap'
            # The Indonesian sentence names both the formula argument and its
            # unique main-operator occurrence explicitly; source prose uses
            # only the latter token at the corresponding point.
            $result = Replace-Exact $result 'every !!{formula} must have exactly one !!{main operator} occurrence' `
                'every !!{formula} must have exactly one !!{formula} !!{main operator} occurrence' 1 `
                'unique-readability/explicit-formula-token'
        }
        'content/first-order-logic/syntax-and-semantics/main-operator.tex' {
            $result = Replace-Exact $result ("!!{main" + "`n" + '  operator}') '!!{main operator}' 1 `
                'main-operator/semantic-token-line-wrap'
            $result = Replace-Exact $result 'the main operator of $\lnot !A$' `
                'the !!{main operator} of $\lnot !A$' 1 'main-operator/example-negation-token'
            $result = Replace-Exact $result 'the main operator of $(!A \lor !B)$' `
                'the !!{main operator} of $(!A \lor !B)$' 1 'main-operator/example-disjunction-token'
            $result = Replace-Exact $result 'which symbol their !!{main operator}' `
                'which symbol their !!{main operator} !!{main operator}' 1 'main-operator/classification-token'
        }
        'content/first-order-logic/syntax-and-semantics/subformulas.tex' {
            $result = Replace-Exact $result '\olsection{\printtoken{P}{subformula}}' `
                '\olsection{\printtoken{P}{subformula}} !!{subformula}' 1 `
                'subformulas/section-title-token-localization'
        }
        'content/first-order-logic/syntax-and-semantics/substitution.tex' {
            $result = Replace-Exact $result '$\Obj v_8$ is free for $\Obj v_1$' `
                '$\Obj v_8$ is !!{free for} $\Obj v_1$' 1 `
                'substitution/example-free-for-token'
            $result = Replace-Exact $result 'is \emph{not} free for $\Obj' `
                'is \emph{not} !!{free for} $\Obj' 1 `
                'substitution/example-not-free-for-token'
            $result = Replace-Exact $result 'assumed to be free for $x$' `
                'assumed to be !!{free for} $x$' 1 `
                'substitution/assumed-free-for-token'
            $result = Replace-Exact $result "term that's free for~`$x`$" `
                "term that's !!{free for}~`$x`$" 1 `
                'substitution/instance-free-for-token'
        }
    }
    return $result
}

function Replace-ProseArgument([string]$Text, [string]$Command) {
    $needle = "\$Command{"
    $builder = [Text.StringBuilder]::new()
    $index = 0
    while ($index -lt $Text.Length) {
        if (($index + $needle.Length -le $Text.Length) -and ($Text.Substring($index, $needle.Length) -ceq $needle)) {
            [void]$builder.Append("\$Command{<TEXT>}")
            $index += $needle.Length
            $depth = 1
            while ($index -lt $Text.Length -and $depth -gt 0) {
                if ($Text[$index] -eq '\' -and $index + 1 -lt $Text.Length) { $index += 2; continue }
                if ($Text[$index] -eq '{') { $depth++ } elseif ($Text[$index] -eq '}') { $depth-- }
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

function Normalize-Math([string]$Text) {
    $result = Replace-ProseArgument $Text 'text'
    $result = Replace-ProseArgument $result 'textrm'
    $result = Replace-ProseArgument $result 'intertext'
    $result = Replace-ProseArgument $result 'emph'
    return [regex]::Replace($result, '[\s~]+', '')
}

function Get-MathSkeletons([string]$Text) {
    $items = [Collections.Generic.List[string]]::new()
    foreach ($match in [regex]::Matches($Text, '(?<!\\)\$(.*?)(?<!\\)\$', 'Singleline')) {
        $items.Add('INLINE:' + (Normalize-Math $match.Value))
    }
    foreach ($match in [regex]::Matches($Text, '\\\[(.*?)\\\]', 'Singleline')) {
        $items.Add('DISPLAY:' + (Normalize-Math $match.Value))
    }
    return @($items)
}

function Get-MathEnvironmentStructures([string]$Text) {
    return @([regex]::Matches(
        $Text,
        '\\begin\{(?<environment>align\*?|multline\*?|equation\*?)\}(?<body>.*?)\\end\{\k<environment>\}',
        'Singleline'
    ) | ForEach-Object {
        $body = Replace-ProseArgument $_.Groups['body'].Value 'text'
        $body = Replace-ProseArgument $body 'intertext'
        $_.Groups['environment'].Value + ':' + (Normalize-Math $body)
    })
}

function Get-CommandSequence([string]$Text) {
    return @(Get-Sequence $Text '(?<value>\\[A-Za-z@]+|\\.)')
}

function Get-SemanticTokenNames([string]$Text) {
    return @([regex]::Matches($Text, '!!(?:\^)?(?:a|A)?\{(?<value>[^{}]+)\}(?:s|d)?', 'Singleline') |
        ForEach-Object { [regex]::Replace($_.Groups['value'].Value, '\s+', ' ') } | Sort-Object)
}

function Assert-Correction([pscustomobject]$Correction, [hashtable]$RawSource, [hashtable]$RawTarget) {
    $sourceCount = ([regex]::Matches($RawSource[$Correction.Path], $Correction.SourceRegex, 'Singleline')).Count
    $targetCount = ([regex]::Matches($RawTarget[$Correction.Path], $Correction.TargetRegex, 'Singleline')).Count
    Assert-Exact ($sourceCount -eq $Correction.SourceCount) "correction-source/$($Correction.Name)" "count=$sourceCount"
    Assert-Exact ($targetCount -eq $Correction.TargetCount) "correction-target/$($Correction.Name)" "count=$targetCount"
    if ($Correction.BadTargetRegex) {
        $badTargetCount = ([regex]::Matches($RawTarget[$Correction.Path], $Correction.BadTargetRegex, 'Singleline')).Count
        Assert-Exact ($badTargetCount -eq 0) "correction-target-removed/$($Correction.Name)" 'count=0'
    }
    $script:sourceCorrectionClasses++
    $script:sourceCorrectionOccurrences += $sourceCount
    $script:targetCorrectionAssertions++
}

function Assert-TargetReview([hashtable]$RawTarget, [string]$Path, [string]$Name, [string]$Pattern, [int]$ExpectedCount) {
    $actual = ([regex]::Matches($RawTarget[$Path], $Pattern, 'Singleline')).Count
    Assert-Exact ($actual -eq $ExpectedCount) "target-review/$Name" "count=$actual"
    $script:targetReviewAssertions++
}

$commitType = @(& git -C $repoRoot cat-file -t $expectedCommit 2>$null)
Assert-Exact (($LASTEXITCODE -eq 0) -and $commitType.Count -eq 1 -and $commitType[0] -ceq 'commit') `
    'frozen-source-commit-object' $expectedCommit
Assert-Exact (Test-Path -LiteralPath $manifestPath) 'closure-manifest-present' $manifestPath

$manifest = Import-Csv -LiteralPath $manifestPath
$manifestBatch = @($manifest | Where-Object {
    [int]$_.stable_order -ge 149 -and [int]$_.stable_order -le 158
} | Sort-Object { [int]$_.stable_order })
Assert-Exact ($manifestBatch.Count -eq $units.Count) 'manifest-batch-count' "count=$($units.Count)"
Assert-Sequence 'manifest/ordered-closure-ids' @($units.Id) @($manifestBatch.closure_id)

$literalPatterns = [ordered]@{
    environments = '(?<value>\\(?:begin|end)\{[^{}]+\})'
    labels = '(?<value>\\ollabel\{[^{}]+\})'
    references = '(?<value>\\(?:olref|Olref)(?:\[[^\]]*\]){0,3}\{[^{}]+\})'
    citations = '(?<value>\\cite[a-zA-Z]*\{[^{}]+\})'
    assets = '(?<value>\\olasset(?:\[[^\]]*\])?\{[^{}]+\})'
    imports = '(?<value>\\olimport\*?(?:\[[^\]]*\])?\{[^{}]+\})'
    tagged_items = '\\(?:tagitem|tagprob|tagendprob)\{(?<value>[^{}]+)\}'
    tag_conditionals = '\\iftag\{(?<value>[^{}]+)\}'
}

$rawSource = @{}
$rawTarget = @{}
$sourceDigestRecords = [Collections.Generic.List[string]]::new()
$targetDigestRecords = [Collections.Generic.List[string]]::new()

for ($unitIndex = 0; $unitIndex -lt $units.Count; $unitIndex++) {
    $unit = $units[$unitIndex]
    $sourceRelative = $unit.Path
    $targetRelative = "locale/id/$sourceRelative"
    $sourcePath = Join-Path $repoRoot ($sourceRelative -replace '/', '\')
    $targetPath = Join-Path $repoRoot ($targetRelative -replace '/', '\')
    $row = $manifestBatch[$unitIndex]

    Assert-Exact (
        $row.closure_id -ceq $unit.Id -and
        [int]$row.stable_order -eq (149 + $unitIndex) -and
        $row.source_commit -ceq $expectedCommit -and
        $row.source_path -ceq $sourceRelative -and
        $row.source_sha256.ToLowerInvariant() -ceq $unit.SourceHash -and
        $row.target_path -ceq $targetRelative -and
        $row.closure_included -ceq 'true' -and
        $row.canonical_reader_reachable -ceq 'true'
    ) "$($unit.Id)/manifest-binding"

    Assert-Exact (Test-Path -LiteralPath $sourcePath) "$($unit.Id)/source-worktree-present"
    Assert-Exact (Test-Path -LiteralPath $targetPath) "$($unit.Id)/target-present"
    Assert-Exact ((Get-Sha256 $sourcePath) -ceq $unit.SourceHash) "$($unit.Id)/source-worktree-hash" $unit.SourceHash

    $resolvedBlob = @(& git -C $repoRoot rev-parse --verify "$expectedCommit`:$sourceRelative" 2>$null)
    Assert-Exact (
        $LASTEXITCODE -eq 0 -and $resolvedBlob.Count -eq 1 -and $resolvedBlob[0] -ceq $unit.SourceBlob
    ) "$($unit.Id)/source-git-object" $unit.SourceBlob
    $blobBytes = Invoke-GitBytes @('cat-file', 'blob', $unit.SourceBlob)
    Assert-Exact ($blobBytes.Length -gt 0) "$($unit.Id)/source-git-object-nonempty" "bytes=$($blobBytes.Length)"
    Assert-Exact ((Get-Sha256 $targetPath) -ceq $unit.TargetHash) "$($unit.Id)/target-hash" $unit.TargetHash

    $sourceTextRaw = Normalize-Newlines ([Text.Encoding]::UTF8.GetString($blobBytes))
    $targetTextRaw = Normalize-Newlines ([IO.File]::ReadAllText($targetPath))
    $rawSource[$sourceRelative] = $sourceTextRaw
    $rawTarget[$sourceRelative] = $targetTextRaw
    $source = Remove-TexComments (Get-CorrectedSourceForReplay $sourceRelative $sourceTextRaw)
    $target = Remove-TexComments $targetTextRaw

    Assert-Exact ((Get-BraceBalance $sourceTextRaw) -eq 0) "$($unit.Id)/source-brace-balance"
    Assert-Exact ((Get-BraceBalance $targetTextRaw) -eq 0) "$($unit.Id)/target-brace-balance"

    $sourceCommands = @(Get-CommandSequence $source)
    $targetCommands = @(Get-CommandSequence $target)
    Assert-Sequence "$($unit.Id)/commands" $sourceCommands $targetCommands
    $totals.commands += $targetCommands.Count

    foreach ($patternName in $literalPatterns.Keys) {
        $sourceItems = @(Get-Sequence $source $literalPatterns[$patternName])
        $targetItems = @(Get-Sequence $target $literalPatterns[$patternName])
        Assert-Sequence "$($unit.Id)/$patternName" $sourceItems $targetItems
        $totals[$patternName] += $targetItems.Count
    }

    $sourceTokens = @(Get-SemanticTokenNames (Get-CorrectedSourceForTokenReplay $sourceRelative $source))
    $targetTokens = @(Get-SemanticTokenNames $target)
    Assert-Sequence "$($unit.Id)/semantic-token-multiset" $sourceTokens $targetTokens
    $totals.semantic_tokens += $targetTokens.Count

    $sourceMath = @(Get-MathSkeletons $source)
    $targetMath = @(Get-MathSkeletons $target)
    Assert-Sequence "$($unit.Id)/normalized-math-skeletons" $sourceMath $targetMath
    $totals.math_skeletons += $targetMath.Count

    $sourceMathEnvironments = @(Get-MathEnvironmentStructures $source)
    $targetMathEnvironments = @(Get-MathEnvironmentStructures $target)
    Assert-Sequence "$($unit.Id)/normalized-math-environments" $sourceMathEnvironments $targetMathEnvironments
    $totals.math_environments += $targetMathEnvironments.Count

    $sourceFileIds = @([regex]::Matches($source, '\\olfileid(?:\[[^\]]+\])?'))
    $targetFileIds = @([regex]::Matches($target, '\\olfileid\[id\]'))
    Assert-Exact ($sourceFileIds.Count -eq $targetFileIds.Count) "$($unit.Id)/localized-file-ids" "count=$($targetFileIds.Count)"
    $totals.localized_file_ids += $targetFileIds.Count

    $sourceChapterIds = @([regex]::Matches($source, '\\olchapter(?:\[[^\]]+\])?'))
    $targetChapterIds = @([regex]::Matches($target, '\\olchapter(?!\[)'))
    Assert-Exact ($sourceChapterIds.Count -eq $targetChapterIds.Count) "$($unit.Id)/chapter-ids" "count=$($targetChapterIds.Count)"
    $totals.chapter_ids += $targetChapterIds.Count

    $sourceDigestRecords.Add("$($unit.Id)|$($unit.SourceBlob)|$($unit.SourceHash)|$sourceRelative")
    $targetDigestRecords.Add("$($unit.Id)|$($unit.TargetHash)|$targetRelative")
}

$declaredCorrections = @(
    [pscustomobject]@{ Name='first-order-languages/nested-iftag-closure'; Path='content/first-order-logic/syntax-and-semantics/first-order-languages.tex'; SourceRegex='\\iftag\{defTrue\}\{\\ycomma !!\{truth\}~\$\\ltrue\$\}\}\{\}\.'; SourceCount=1; TargetRegex='\\iftag\{defTrue\}\{\\ycomma !!\{truth\}~\$\\ltrue\$\}\{\}\.\}\{\}'; TargetCount=1; BadTargetRegex='\\iftag\{defTrue\}\{\\ycomma !!\{truth\}~\$\\ltrue\$\}\}\{\}\.' }
    [pscustomobject]@{ Name='terms-formulas/unmatched-parenthesis'; Path='content/first-order-logic/syntax-and-semantics/terms-formulas.tex'; SourceRegex='\$\\lnot !A \\lor !B\)\$'; SourceCount=1; TargetRegex='\$\\lnot !A \\lor !B\$'; TargetCount=1; BadTargetRegex='\$\\lnot !A \\lor !B\)\$' }
    [pscustomobject]@{ Name='main-operator/conjunction-parenthesis-math-mode'; Path='content/first-order-logic/syntax-and-semantics/main-operator.tex'; SourceRegex='\$\(!A \\land !B\$\)'; SourceCount=1; TargetRegex='\$\(!A \\land !B\)\$'; TargetCount=1; BadTargetRegex='\$\(!A \\land !B\$\)' }
    [pscustomobject]@{ Name='main-operator/disjunction-parenthesis-math-mode'; Path='content/first-order-logic/syntax-and-semantics/main-operator.tex'; SourceRegex='\$\(!A \\lor !B\$\)'; SourceCount=1; TargetRegex='\$\(!A \\lor !B\)\$'; TargetCount=2; BadTargetRegex='\$\(!A \\lor !B\$\)' }
    [pscustomobject]@{ Name='main-operator/conditional-parenthesis-math-mode'; Path='content/first-order-logic/syntax-and-semantics/main-operator.tex'; SourceRegex='\$\(!A \\lif !B\$\)'; SourceCount=1; TargetRegex='\$\(!A \\lif !B\)\$'; TargetCount=1; BadTargetRegex='\$\(!A \\lif !B\$\)' }
    [pscustomobject]@{ Name='formation-sequences/k-ary-indices'; Path='content/first-order-logic/syntax-and-semantics/formation-sequences.tex'; SourceRegex='m_0'; SourceCount=2; TargetRegex='m_1'; TargetCount=2; BadTargetRegex='m_0' }
    [pscustomobject]@{ Name='formation-sequences/induction-measure'; Path='content/first-order-logic/syntax-and-semantics/formation-sequences.tex'; SourceRegex='formation sequence of length \$m < n\$'; SourceCount=1; TargetRegex='barisan pembentukan berindeks terakhir \$m < n\$'; TargetCount=1; BadTargetRegex='barisan pembentukan dengan panjang \$m < n\$' }
    [pscustomobject]@{ Name='formation-sequences/language-subscript'; Path='content/first-order-logic/syntax-and-semantics/formation-sequences.tex'; SourceRegex='\\Frm\[L_0\]'; SourceCount=2; TargetRegex='\\Frm\[L\]'; TargetCount=7; BadTargetRegex='\\Frm\[L_0\]' }
    [pscustomobject]@{ Name='formation-sequences/syntactic-identity'; Path='content/first-order-logic/syntax-and-semantics/formation-sequences.tex'; SourceRegex='\$!A \\equiv \(!A_j \\land !A_k\)\$'; SourceCount=1; TargetRegex='\$!A \\ident\s+\(!A_j \\land !A_k\)\$'; TargetCount=2; BadTargetRegex='\$!A \\equiv \(!A_j \\land !A_k\)\$' }
    [pscustomobject]@{ Name='formation-sequences/indonesian-subformula-token'; Path='content/first-order-logic/syntax-and-semantics/formation-sequences.tex'; SourceRegex='sub-!!\{formula\}'; SourceCount=1; TargetRegex='!!\{subformula\}'; TargetCount=1; BadTargetRegex='(?:sub-|sub)!!\{formula\}' }
)

foreach ($correction in $declaredCorrections) {
    Assert-Correction $correction $rawSource $rawTarget
}

# Bind editorial corrections and the three parent-owned locale prerequisites.
Assert-TargetReview $rawTarget 'content/first-order-logic/syntax-and-semantics/intro-syntax.tex' `
    'editorial/chose-corrected-by-translation' 'Sistem lain akan memilih simbol' 1
Assert-TargetReview $rawTarget 'content/first-order-logic/syntax-and-semantics/unique-readability.tex' `
    'editorial/intepretation-corrected-by-translation' 'lebih dari satu\s+pembacaan atau penafsiran' 1
Assert-TargetReview $rawTarget 'content/first-order-logic/syntax-and-semantics/first-order-languages.tex' `
    'editorial/duplicated-comma-corrected-by-translation' 'falsum.{1,20}absurditas' 1
Assert-TargetReview $rawTarget 'content/first-order-logic/syntax-and-semantics/formation-sequences.tex' `
    'localization/subformula-token-native' '!!\{subformula\} dari~\$!A\$' 1

$configPath = Join-Path $localeRoot 'open-logic-config.sty'
Assert-Exact (Test-Path -LiteralPath $configPath) 'parent-prerequisite/config-present'
$config = Normalize-Newlines ([IO.File]::ReadAllText($configPath))
Assert-Exact ([regex]::IsMatch($config, '\\settexttoken\{subformula\}\{subformula\}\{subformula\}')) `
    'parent-prerequisite/subformula-token'
Assert-Exact ([regex]::IsMatch($config, '\\settexttoken\{free for\}\{bebas disubstitusikan bagi\}\{bebas disubstitusikan bagi\}')) `
    'parent-prerequisite/free-for-token'
Assert-Exact ([regex]::IsMatch($config, '\\RenewDocumentCommand \\indcase .*\$#3\$ atomik: .*latihan\.', 'Singleline')) `
    'parent-prerequisite/localized-indcase'

$allTarget = ($units | ForEach-Object { $rawTarget[$_.Path] }) -join "`n"
Assert-Exact (-not [regex]::IsMatch($allTarget, '\\olfileid(?!\[id\])')) 'batch/all-file-identifiers-id'
Assert-Exact (-not [regex]::IsMatch($rawTarget['content/first-order-logic/syntax-and-semantics/syntax.tex'], '\\olchapter\[id\]')) `
    'batch/chapter-command-not-locale-overloaded'
Assert-Exact (-not [regex]::IsMatch($allTarget, '(?i)\b(chose|intepretation)\b')) 'batch/upstream-editorial-typos-absent'

Assert-Exact ($sourceCorrectionClasses -eq 10) 'batch/source-correction-class-count' 'count=10'
Assert-Exact ($sourceCorrectionOccurrences -eq 12) 'batch/source-correction-occurrence-count' 'count=12'
Assert-Exact ($targetCorrectionAssertions -eq 10) 'batch/target-correction-assertion-count' 'count=10'
Assert-Exact ($targetReviewAssertions -eq 4) 'batch/target-review-assertion-count' 'count=4'

# Frozen post-replay aggregates prevent a weakened parser from passing merely
# because source and target fail symmetrically. Commands include all 16 olref
# command occurrences; environments count ordered begin and end commands.
$expectedTotals = [ordered]@{
    commands = 1430
    environments = 226
    semantic_tokens = 256
    labels = 20
    references = 16
    citations = 2
    assets = 0
    imports = 9
    tagged_items = 90
    tag_conditionals = 47
    math_skeletons = 793
    math_environments = 1
    localized_file_ids = 9
    chapter_ids = 1
}
foreach ($entry in $expectedTotals.GetEnumerator()) {
    Assert-Exact ($totals[$entry.Key] -eq $entry.Value) "batch/frozen-total-$($entry.Key)" "count=$($entry.Value)"
}

$sourceSetDigest = Get-TextDigest @($sourceDigestRecords)
$targetSetDigest = Get-TextDigest @($targetDigestRecords)
foreach ($unit in $units) { Write-Output "TARGET_HASH $($unit.Id) $($unit.Path) $($unit.TargetHash)" }
Write-Output ("STRUCTURAL_TOTALS commands={0} environments={1} semantic_tokens={2} labels={3} references={4} citations={5} assets={6} imports={7} tagged_items={8} tag_conditionals={9} math_skeletons={10} math_environments={11} localized_file_ids={12} chapter_ids={13}" -f `
    $totals.commands, $totals.environments, $totals.semantic_tokens, $totals.labels,
    $totals.references, $totals.citations, $totals.assets, $totals.imports,
    $totals.tagged_items, $totals.tag_conditionals, $totals.math_skeletons,
    $totals.math_environments, $totals.localized_file_ids, $totals.chapter_ids)
Write-Output "CORRECTION_TOTALS classes=$sourceCorrectionClasses source_occurrences=$sourceCorrectionOccurrences target_assertions=$targetCorrectionAssertions target_review_assertions=$targetReviewAssertions"
Write-Output "BINDING_DIGESTS source_set_sha256=$sourceSetDigest target_set_sha256=$targetSetDigest"
Write-Output "FOL_SYNTAX_BATCH_REPLAY_OK files=$($units.Count) checks=$checks upstream=$expectedCommit closure=OLP-0149..OLP-0158"
