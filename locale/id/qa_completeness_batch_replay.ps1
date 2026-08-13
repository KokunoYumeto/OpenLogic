$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$localeRoot = $PSScriptRoot
$repoRoot = [IO.Path]::GetFullPath((Join-Path $localeRoot '..\..'))
$controlRoot = [IO.Path]::GetFullPath((Join-Path $repoRoot '..\_control'))
$manifestPath = Join-Path $controlRoot 'OPENLOGIC_CLOSURE_MANIFEST_20260812.csv'
$expectedCommit = '9620cc73f9c8e0ad003c514a5d3748f29611c4c0'
$relativeDir = 'content/first-order-logic/completeness'

# Manifest source hashes bind the frozen, worktree-normalized English bytes.
# Target hashes freeze the final independently reviewed Indonesian bytes.
$units = @(
    [pscustomobject]@{ Id='OLP-0126'; Name='completeness.tex';              SourceBlob='1fec6685c892798f07d2453f995df662ae2d7258'; SourceHash='35cbcfc7f12046ceabc5c4407c43817d71d3907e9e9d57a1b5928fcbe10c672c'; TargetHash='8c37c6b2859e9c2a15e87415d96f7871763c33b7e90488d3c82d3b5d3be14626' }
    [pscustomobject]@{ Id='OLP-0127'; Name='introduction.tex';              SourceBlob='3a716099e922c11970c8cbe918de6955372635ef'; SourceHash='40a994a78343dccb102c8347722a6eb85fd3a12dd4c6565a37960f7b24673500'; TargetHash='fff1d19d5ad4cef78ae3f2405339f53e0cf361c8df10dad988f3018e74d08db5' }
    [pscustomobject]@{ Id='OLP-0128'; Name='outline.tex';                   SourceBlob='8a593dfad9e1e29d3b3c04f01fdc36fdbdc11080'; SourceHash='e86bb4893ff5da65af4fa5b8b7eebec5807e0b4aa0562ca5388fac369aec642e'; TargetHash='ff7e4fa34dd63a583581cf8dab632cece08fb1dda01a1f29c4d284774f7350a9' }
    [pscustomobject]@{ Id='OLP-0129'; Name='complete-consistent-sets.tex';  SourceBlob='c172ac9858e2cb593978eaad4ee66621d4893dca'; SourceHash='cf7d517de5d2d257492c66f2cf16347fce490f2d932681a3f6ebd2386e9b1ffd'; TargetHash='511b66430c9ccff411eeacd30e9145672a8b7a6bb49665138e8242be1d9874b9' }
    [pscustomobject]@{ Id='OLP-0130'; Name='henkin-expansions.tex';         SourceBlob='17f6331f8324bba35fa72fb0e987361ec0e59758'; SourceHash='a42f0551e062db3102c47f082be24cd4f8506504989a0008df4b87564e1f9335'; TargetHash='d00d41c555d837a5e9ed351d56512e699994e60a7efedac35a75365a2b30c6fc' }
    [pscustomobject]@{ Id='OLP-0131'; Name='lindenbaums-lemma.tex';         SourceBlob='7f89a297fbb196d3022dd7028ca403cdad5d84e0'; SourceHash='1ee3d9dd14df1c3368c3e7a12d68e4d6627b9e92030a00820270b75ceb4bdf78'; TargetHash='8c079a681f431f7503f3568da11e8170fb36aa13db2cec985334fdddc4011c7b' }
    [pscustomobject]@{ Id='OLP-0132'; Name='construction-of-model.tex';     SourceBlob='ed9f84ba5e484375f951b9519c0cb78d618836de'; SourceHash='e8f3c25a2b378ac1996cc9cebb1192b2bdc2527df547e922008dad3822d29969'; TargetHash='fbe2f57f7a2816e93c5bf79b782bca6c09be6046c8c756fecd87e3aba0f83f00' }
    [pscustomobject]@{ Id='OLP-0133'; Name='identity.tex';                  SourceBlob='6fac88f7cac8638281666c857b1e002a6bf87695'; SourceHash='2b497ead07aad76f2db101bd56768abd9bc71df7c819164edf0183656d148e7d'; TargetHash='a942eae602d6c4c17e5c15bdf604fbcb62278e42bb4f7539bc075b559f5b8b19' }
    [pscustomobject]@{ Id='OLP-0134'; Name='completeness-thm.tex';          SourceBlob='62945d5c79f643496d63b0cb736d095b12dd830f'; SourceHash='5510644c6a3ff18e97d5e97a928d00cb0b091506e8c10bafa504c1b2c38b242b'; TargetHash='4b0bac6de38c3bff7964d7a6a3ddea772c3e89d3deb34728d9c670a85daf5390' }
    [pscustomobject]@{ Id='OLP-0135'; Name='compactness.tex';               SourceBlob='37149d2c9386386902a4d008a6556ef949860a5a'; SourceHash='a872b7018576b26eb53179792e27b5b0af3338b5220712086e1be7d928b3d65c'; TargetHash='f2fc3640457ef267ef280c20867bdd8531be3968cb2a6e826b7478afcd5b25dd' }
    [pscustomobject]@{ Id='OLP-0136'; Name='compactness-direct.tex';        SourceBlob='19e31ad82b3621f151e3910b587ec80f2ad7fe51'; SourceHash='e6398fcc96ac7a2e787c5128d1b2dbf8f515dbd0e780004831abcfd0c3f327d8'; TargetHash='fd3eb3eefc7ca9366e8bfb896ab48a2a61e81113c567d1818eb4a7ea2f495e9a' }
    [pscustomobject]@{ Id='OLP-0137'; Name='downward-ls.tex';               SourceBlob='5db185696035d6053770d3ca0edeaa2661560a64'; SourceHash='6f442281e52dd720acdd540039544c4e8b998906154aa5c4cf7f5da0d9500c48'; TargetHash='87a14432bcdb4f64fec2b14edd267aba0a46df6c9c856f991aae38882172b261' }
)

$sourceDir = Join-Path $repoRoot ($relativeDir -replace '/', '\')
$targetDir = Join-Path $localeRoot ($relativeDir -replace '^content/', 'content/' -replace '/', '\')
$checks = 0
$sourceCorrectionClasses = 0
$sourceCorrectionOccurrences = 0
$targetCorrectionAssertions = 0
$totals = [ordered]@{
    commands = 0
    environments = 0
    semantic_tokens = 0
    labels = 0
    references = 0
    citations = 0
    assets = 0
    imports = 0
    tag_keys = 0
    math_skeletons = 0
    math_environments = 0
    localized_file_ids = 0
    localized_chapter_ids = 0
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

function Get-CorrectedSourceForReplay([string]$Name, [string]$Text) {
    $result = Normalize-Newlines $Text
    switch ($Name) {
        'henkin-expansions.tex' {
            $result = Replace-Exact $result '$\lforall[x_n][\lnot !A_n]$ is defined as' `
                '$\lforall[x_n][\lnot !A_n(x_n)]$ is defined as' 1 'henkin/formula-instance'
            $result = Replace-Exact $result `
                '\iftag{prvAll}{it contains an' `
                '\iftag{prvEx}{it contains an' 1 'henkin/existential-tag'
        }
        'lindenbaums-lemma.tex' {
            $result = Replace-Exact $result `
                'Each $\Gamma_n$ is consistent: $\Gamma_0$ is consistent by definition.' `
                'Each $\Gamma_n$ is consistent: $\Gamma_0$ is consistent by hypothesis and definition of~$\Gamma_0$.' `
                1 'lindenbaum/base-hypothesis'
            $old = "Let`n`$\Gamma' \subseteq \Gamma^*`$ be finite. Each `$!B \in \Gamma'`$ is also"
            $new = "Let`n`$\Gamma' \subseteq \Gamma^*`$ be finite. If `$\Gamma'=\varnothing`$, then `$\Gamma'`$ is trivially consistent. If `$\Gamma'\ne\varnothing`$, each `$!B \in \Gamma'`$ is also"
            $result = Replace-Exact $result $old $new 1 'lindenbaum/empty-finite-subset'
        }
        'construction-of-model.tex' {
            $result = Replace-Exact $result '$\lforall[x][!A(x)] \in \Gamma^*$.' `
                '$\lforall[x][!B(x)] \in \Gamma^*$.' 1 'term-model/universal-truth-variable'
        }
        'identity.tex' {
            $result = Replace-Exact $result `
                '\Atom{f}{t_1,\dots,t_{i-1},t,t_{i+1},,\dots,t_n}' `
                '\Atom{f}{t_1,\dots,t_{i-1},t,t_{i+1},\dots,t_n}' 1 'identity/duplicate-comma'
            $result = Replace-Exact $result `
                '\equivrep{t}{\approx} = \Setabs{t''}{t''\in \Trm[L], t \approx t''}' `
                '\equivrep{t}{\approx} = \Setabs{t''}{t''\in \Trm[L],\ t'' \text{ closed},\ t \approx t''}' `
                1 'identity/closed-representatives'
            $result = Replace-Exact $result `
                '$\equivclass{\Trm[L]}{\approx} = \Setabs{\equivrep{t}{\approx}}{t \in \Trm[L]}$.' `
                '$\equivclass{\Setabs{t}{t \in \Trm[L],\ t \text{ closed}}}{\approx} = \Setabs{\equivrep{t}{\approx}}{t \in \Trm[L],\ t \text{ closed}}$.' `
                1 'identity/closed-carrier-equation'
            $result = Replace-Exact $result `
                '$\Domain{\equivclass{M}{\approx}} = \equivclass{\Trm[L]}{\approx}$.' `
                '$\Domain{\equivclass{M}{\approx}} = \equivclass{\Setabs{t}{t \in \Trm[L],\ t \text{ closed}}}{\approx}$.' `
                1 'identity/closed-domain'
            $result = Replace-Exact $result `
                '$\equivclass{\Trm[L]}{\approx}$ by referring to them as' `
                '$\equivclass{\Setabs{t}{t \in \Trm[L],\ t \text{ closed}}}{\approx}$ by referring to them as' `
                1 'identity/closed-carrier-prose'
            $result = Replace-Exact $result '$\Sat/{M}{\Atom{R}{t}}$' `
                '$\Sat/{M}{\Atom{R}{t''}}$' 1 'identity/predicate-alternate-representative'
        }
        'compactness.tex' {
            $result = Replace-Exact $result `
                '\Delta = \Setabs{\eq/[c][t]}{t \in \Trm[L]}.' `
                '\Delta = \Setabs{\eq/[c][t]}{t \in \Trm[L],\ t \text{ closed}}.' `
                1 'compactness/closed-term-delta'
        }
        'compactness-direct.tex' {
            $old = 'references to \olref[ccs]{prop:ccs}\iftag{FOL}{ and' + "`n" +
                '\olref[hen]{prop:saturated-instances} by references to' + "`n" +
                '\olref{prop:fsat-ccs} and \olref{prop:fsat-instances}}.'
            $new = 'references to \olref[ccs]{prop:ccs} by references to' + "`n" +
                '\olref{prop:fsat-ccs}\iftag{FOL}{, and references to' + "`n" +
                '\olref[hen]{prop:saturated-instances} by references to \olref{prop:fsat-instances}}.'
            $result = Replace-Exact $result $old $new 1 'compactness-direct/PL-reference-scope'
        }
        'downward-ls.tex' {
            $result = Replace-Exact $result 'the terms of the language~$\Lang L$.' `
                'the closed terms of the expanded language~$\Lang{L''}$.' `
                1 'downward-ls/expanded-closed-language'
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
    return @((Get-Sequence $Text '(?<value>\\[A-Za-z@]+|\\.)') | Where-Object {
        $_ -cne '\olref' -and $_ -cne '\Olref'
    })
}

function Get-SemanticTokenNames([string]$Text) {
    return @([regex]::Matches($Text, '!!(?:\^)?(?:a|A)?\{(?<value>[^{}]+)\}(?:s|d)?', 'Singleline') |
        ForEach-Object { [regex]::Replace($_.Groups['value'].Value, '\s+', ' ') } | Sort-Object)
}

function Assert-Correction([pscustomobject]$Correction, [hashtable]$RawSource, [hashtable]$RawTarget) {
    $sourceCount = ([regex]::Matches($RawSource[$Correction.File], $Correction.SourceRegex, 'Singleline')).Count
    $targetCount = ([regex]::Matches($RawTarget[$Correction.File], $Correction.TargetRegex, 'Singleline')).Count
    Assert-Exact ($sourceCount -eq $Correction.SourceCount) "correction-source/$($Correction.Name)" "count=$sourceCount"
    Assert-Exact ($targetCount -eq $Correction.TargetCount) "correction-target/$($Correction.Name)" "count=$targetCount"
    $script:sourceCorrectionClasses++
    $script:sourceCorrectionOccurrences += $sourceCount
    $script:targetCorrectionAssertions++
}

$commitType = @(& git -C $repoRoot cat-file -t $expectedCommit 2>$null)
Assert-Exact (($LASTEXITCODE -eq 0) -and $commitType.Count -eq 1 -and $commitType[0] -ceq 'commit') `
    'frozen-source-commit-object' $expectedCommit
Assert-Exact (Test-Path -LiteralPath $manifestPath) 'closure-manifest-present' $manifestPath

$manifest = Import-Csv -LiteralPath $manifestPath
$manifestBatch = @($manifest | Where-Object {
    [int]$_.stable_order -ge 126 -and [int]$_.stable_order -le 137
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
    tag_keys = '\\(?:iftag|tagitem|tagprob|tagendprob)\{(?<value>[^{}]+)\}'
}

$rawSource = @{}
$rawTarget = @{}
$sourceDigestRecords = [Collections.Generic.List[string]]::new()
$targetDigestRecords = [Collections.Generic.List[string]]::new()

for ($unitIndex = 0; $unitIndex -lt $units.Count; $unitIndex++) {
    $unit = $units[$unitIndex]
    $sourceRelative = "$relativeDir/$($unit.Name)"
    $targetRelative = "locale/id/$relativeDir/$($unit.Name)"
    $sourcePath = Join-Path $sourceDir $unit.Name
    $targetPath = Join-Path $targetDir $unit.Name
    $row = $manifestBatch[$unitIndex]

    Assert-Exact (
        $row.closure_id -ceq $unit.Id -and
        [int]$row.stable_order -eq (126 + $unitIndex) -and
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
    $rawSource[$unit.Name] = $sourceTextRaw
    $rawTarget[$unit.Name] = $targetTextRaw
    $source = Remove-TexComments (Get-CorrectedSourceForReplay $unit.Name $sourceTextRaw)
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

    $sourceTokens = @(Get-SemanticTokenNames $source)
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
    $targetChapterIds = @([regex]::Matches($target, '\\olchapter\[id\]'))
    Assert-Exact ($sourceChapterIds.Count -eq $targetChapterIds.Count) "$($unit.Id)/localized-chapter-ids" "count=$($targetChapterIds.Count)"
    $totals.localized_chapter_ids += $targetChapterIds.Count

    $sourceDigestRecords.Add("$($unit.Id)|$($unit.SourceBlob)|$($unit.SourceHash)|$sourceRelative")
    $targetDigestRecords.Add("$($unit.Id)|$($unit.TargetHash)|$targetRelative")
}

$declaredCorrections = @(
    [pscustomobject]@{ Name='introduction/duplicate-determiner'; File='introduction.tex'; SourceRegex='\\emph\{the proof of\} the completeness theorem'; SourceCount=1; TargetRegex='\\emph\{bukti\} teorema\s+kelengkapan'; TargetCount=1 }
    [pscustomobject]@{ Name='outline/sentence-plural'; File='outline.tex'; SourceRegex='all sentence in~\$\\Gamma\$'; SourceCount=1; TargetRegex='semua\s+kalimat dalam~\$\\Gamma\$'; TargetCount=1 }
    [pscustomobject]@{ Name='outline/closed-term-carrier-and-operation'; File='outline.tex'; SourceRegex='let\s+\$\\Domain\{M\}\$ be all \\emph\{terms\} of the language'; SourceCount=1; TargetRegex='tetapkan \$\\Domain\{M\}\$ sebagai himpunan semua \\emph\{suku tertutup\}'; TargetCount=1 }
    [pscustomobject]@{ Name='henkin/missing-matrix-instance'; File='henkin-expansions.tex'; SourceRegex='\\lforall\[x_n\]\[\\lnot !A_n\]\$ is defined as'; SourceCount=1; TargetRegex='\\lforall\[x_n\]\[\\lnot !A_n\(x_n\)\]\$ didefinisikan sebagai'; TargetCount=1 }
    [pscustomobject]@{ Name='henkin/existential-explanation-tag'; File='henkin-expansions.tex'; SourceRegex='\\iftag\{prvAll\}\{it contains an\s+existentially'; SourceCount=1; TargetRegex='\\iftag\{prvEx\}\{himpunan itu memuat suatu !!\{sentence\} berkuantor\s+eksistensial'; TargetCount=1 }
    [pscustomobject]@{ Name='lindenbaum/base-hypothesis'; File='lindenbaums-lemma.tex'; SourceRegex='\\Gamma_0\$ is consistent by definition'; SourceCount=1; TargetRegex='\\Gamma_0\$ konsisten menurut hipotesis dan\s+definisi~\$\\Gamma_0\$'; TargetCount=1 }
    [pscustomobject]@{ Name='lindenbaum/empty-finite-subset'; File='lindenbaums-lemma.tex'; SourceRegex='Let\s+\$\\Gamma'' \\subseteq \\Gamma\^\*\$ be finite\. Each'; SourceCount=1; TargetRegex='\\Gamma''=\\varnothing\$.*\\Gamma''\\ne\\varnothing'; TargetCount=1 }
    [pscustomobject]@{ Name='term-model/value-lemma-closed-terms'; File='construction-of-model.tex'; SourceRegex='We will now check that we indeed have \$\\Value\{t\}\{M\(\\Gamma\^\*\)\} = t\$'; SourceCount=1; TargetRegex='bagi setiap suku tertutup, memang\s+berlaku \$\\Value\{t\}\{M\(\\Gamma\^\*\)\} = t\$'; TargetCount=1 }
    [pscustomobject]@{ Name='term-model/assignment-existence'; File='construction-of-model.tex'; SourceRegex='for every closed term~\$t\$, \$s\(x\) = t\$ is such a variable\s+assignment'; SourceCount=1; TargetRegex='untuk setiap suku tertutup~\$t\$, terdapat suatu\s+penetapan variabel yang memenuhi \$s\(x\) = t\$'; TargetCount=1 }
    [pscustomobject]@{ Name='truth-lemma/quantifier-closed-terms'; File='construction-of-model.tex'; SourceRegex='for (?:all terms|at least one term)~\$t\$'; SourceCount=4; TargetRegex='(?:semua suku tertutup|sekurang-kurangnya satu\s+suku tertutup)~\$t\$'; TargetCount=4 }
    [pscustomobject]@{ Name='truth-lemma/universal-B-matrix'; File='construction-of-model.tex'; SourceRegex='\\lforall\[x\]\[!A\(x\)\] \\in \\Gamma\^\*\$\.'; SourceCount=1; TargetRegex='\\lforall\[x\]\[!B\(x\)\] \\in \\Gamma\^\*\$\.'; TargetCount=1 }
    [pscustomobject]@{ Name='identity/duplicate-comma'; File='identity.tex'; SourceRegex='t_\{i\+1\},,\\dots'; SourceCount=1; TargetRegex='t_\{i\+1\},\\dots'; TargetCount=4 }
    [pscustomobject]@{ Name='identity/closed-quotient-carrier'; File='identity.tex'; SourceRegex='(?:\\equivclass\{\\Trm\[L\]\}\{\\approx\}|\\Setabs\{t''\}\{t''\\in \\Trm\[L\], t \\approx t''\})'; SourceCount=4; TargetRegex='(?:\\equivclass\{\\Setabs\{t\}\{t \\in \\Trm\[L\],\\ t \\text\{ tertutup\}\}\}\{\\approx\}|\\Setabs\{t''\}\{t''\\in \\Trm\[L\],\\ t'' \\text\{ tertutup\},\\ t \\approx t''\})'; TargetCount=4 }
    [pscustomobject]@{ Name='identity/predicate-alternate-representative'; File='identity.tex'; SourceRegex='\\Sat/\{M\}\{\\Atom\{R\}\{t\}\}'; SourceCount=1; TargetRegex='\\Sat/\{M\}\{\\Atom\{R\}\{t''\}\}'; TargetCount=1 }
    [pscustomobject]@{ Name='identity/factored-value-lemma-closed-term'; File='identity.tex'; SourceRegex='then \$\\Value\{t\}\{\\equivclass\{M\}\{\\approx\}\}'; SourceCount=1; TargetRegex='bagi setiap suku tertutup,\s+\$\\Value\{t\}\{\\equivclass\{M\}\{\\approx\}\}'; TargetCount=1 }
    [pscustomobject]@{ Name='compactness/theorem-argument-types'; File='compactness.tex'; SourceRegex='for any sentences \$\\Gamma\$ and \$!A\$'; SourceCount=1; TargetRegex='setiap himpunan kalimat\s+\$\\Gamma\$ dan setiap kalimat~\$!A\$'; TargetCount=1 }
    [pscustomobject]@{ Name='compactness/closed-term-delta'; File='compactness.tex'; SourceRegex='\\Delta = \\Setabs\{\\eq/\[c\]\[t\]\}\{t \\in \\Trm\[L\]\}'; SourceCount=1; TargetRegex='\\Delta = \\Setabs\{\\eq/\[c\]\[t\]\}\{t \\in \\Trm\[L\],\\ t \\text\{ tertutup\}\}'; TargetCount=1 }
    [pscustomobject]@{ Name='compactness/empty-Delta-prime-maximum'; File='compactness.tex'; SourceRegex='Let \$n\$ be the largest number such that \$!A_\{\\ge n\}\s+\\in \\Delta''\$'; SourceCount=1; TargetRegex='Definisikan \$n\$\s+sebagai 1 jika komponen pertama itu kosong'; TargetCount=1 }
    [pscustomobject]@{ Name='compactness-direct/PL-reference-scope'; File='compactness-direct.tex'; SourceRegex='\\olref\[ccs\]\{prop:ccs\}\\iftag\{FOL\}\{ and\s+\\olref\[hen\]\{prop:saturated-instances\} by references to\s+\\olref\{prop:fsat-ccs\}'; SourceCount=1; TargetRegex='\\olref\[ccs\]\{prop:ccs\} diganti dengan rujukan pada\s+\\olref\{prop:fsat-ccs\}\\iftag\{FOL\}'; TargetCount=1 }
    [pscustomobject]@{ Name='downward-ls/expanded-closed-language'; File='downward-ls.tex'; SourceRegex='terms of the language~\$\\Lang L\$'; SourceCount=1; TargetRegex='suku tertutup dari bahasa~\$\\Lang\{L''\}\$'; TargetCount=1 }
    [pscustomobject]@{ Name='downward-ls/denumerability-both-halves'; File='downward-ls.tex'; SourceRegex='!!\{denumerable\}, since \$\\Trm\[L''\]\$ is'; SourceCount=1; TargetRegex='bagian terhitung dari \$\\Trm\[L''\]\$ dan memuat tak hingga banyak konstanta\s+Henkin'; TargetCount=1 }
)

foreach ($correction in $declaredCorrections) {
    Assert-Correction $correction $rawSource $rawTarget
}

$allSource = ($units | ForEach-Object { $rawSource[$_.Name] }) -join "`n"
$allTarget = ($units | ForEach-Object { $rawTarget[$_.Name] }) -join "`n"
Assert-Exact (([regex]::Matches($allSource, [regex]::Escape('!{}'))).Count -eq 2) `
    'retraction/literal-exclamation-source' 'count=2 intentional'
Assert-Exact (([regex]::Matches($allTarget, [regex]::Escape('!{}'))).Count -eq 2) `
    'retraction/literal-exclamation-target' 'count=2 intentional'
Assert-Exact (([regex]::Matches($allSource, [regex]::Escape('!!{denumerable}s'))).Count -eq 1) `
    'retraction/denumerable-plural-token-source' 'count=1 valid'
Assert-Exact (([regex]::Matches($allTarget, [regex]::Escape('!!{denumerable}s'))).Count -eq 1) `
    'retraction/denumerable-plural-token-target' 'count=1 valid'
Assert-Exact (([regex]::Matches($rawTarget['downward-ls.tex'], 'bagian terhitung.*tak hingga banyak konstanta\s+Henkin', 'Singleline')).Count -eq 1) `
    'retraction/countability-convention-resolved'
Assert-Exact (([regex]::Matches($rawTarget['lindenbaums-lemma.tex'], '\$\\Frm\[L\]\$')).Count -eq 1) `
    'preserved/Frm-L-sentence-wording'
Assert-Exact (([regex]::Matches($rawTarget['identity.tex'], '\$t_i \\approx t_i''\$')).Count -eq 1) `
    'preserved/identity-index-scope-wording'
Assert-Exact (([regex]::Matches($rawTarget['compactness-direct.tex'], 'model suku~\$\\Struct\{M\(\\Gamma\^\*\)\}\$')).Count -eq 2) `
    'preserved/compactness-direct-ordinary-term-model-risk' 'count=2'

Assert-Exact ($sourceCorrectionClasses -eq 21) 'batch/source-correction-class-count' 'count=21'
Assert-Exact ($targetCorrectionAssertions -eq 21) 'batch/target-correction-assertion-count' 'count=21'
Assert-Exact (-not [regex]::IsMatch($allTarget, '\\ol(?:fileid|chapter)(?!\[id\])')) `
    'batch/all-locale-identifiers-id'

# Independently frozen aggregates prevent a weakened parser or omitted unit
# from passing merely because source and target fail in the same way.
$expectedTotals = [ordered]@{
    commands = 2423
    environments = 238
    semantic_tokens = 254
    labels = 30
    references = 91
    citations = 0
    assets = 0
    imports = 11
    tag_keys = 182
    math_skeletons = 959
    math_environments = 4
    localized_file_ids = 19
    localized_chapter_ids = 2
}
foreach ($entry in $expectedTotals.GetEnumerator()) {
    Assert-Exact ($totals[$entry.Key] -eq $entry.Value) "batch/frozen-total-$($entry.Key)" "count=$($entry.Value)"
}

$sourceSetDigest = Get-TextDigest @($sourceDigestRecords)
$targetSetDigest = Get-TextDigest @($targetDigestRecords)
foreach ($unit in $units) { Write-Output "TARGET_HASH $($unit.Id) $($unit.Name) $($unit.TargetHash)" }
Write-Output ("STRUCTURAL_TOTALS commands={0} environments={1} semantic_tokens={2} labels={3} references={4} citations={5} assets={6} imports={7} tag_keys={8} math_skeletons={9} math_environments={10} localized_file_ids={11} localized_chapter_ids={12}" -f `
    $totals.commands, $totals.environments, $totals.semantic_tokens, $totals.labels,
    $totals.references, $totals.citations, $totals.assets, $totals.imports,
    $totals.tag_keys, $totals.math_skeletons, $totals.math_environments,
    $totals.localized_file_ids, $totals.localized_chapter_ids)
Write-Output "CORRECTION_TOTALS classes=$sourceCorrectionClasses source_occurrences=$sourceCorrectionOccurrences target_assertions=$targetCorrectionAssertions"
Write-Output "BINDING_DIGESTS source_set_sha256=$sourceSetDigest target_set_sha256=$targetSetDigest"
Write-Output "COMPLETENESS_BATCH_REPLAY_OK files=$($units.Count) checks=$checks upstream=$expectedCommit closure=OLP-0126..OLP-0137"
