$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$localeRoot = $PSScriptRoot
$repoRoot = [IO.Path]::GetFullPath((Join-Path $localeRoot '..\..'))
$controlRoot = [IO.Path]::GetFullPath((Join-Path $repoRoot '..\_control'))
$manifestPath = Join-Path $controlRoot 'OPENLOGIC_CLOSURE_MANIFEST_20260812.csv'
$expectedCommit = '9620cc73f9c8e0ad003c514a5d3748f29611c4c0'

# Source hashes bind the worktree-normalized bytes recorded in the closure
# manifest. SourceBlob binds the immutable Git object at expectedCommit.
# TargetHash freezes the live, post-independent-review Indonesian bytes.
$units = @(
    [pscustomobject]@{ Id='OLP-0138'; Path='content/first-order-logic/first-order-logic.tex';                    SourceBlob='159f9bc0195526828d653f1334be672cddbfab95'; SourceHash='3fee444ae39c4094bd1bb1963010c0bf6350b5702c79d9e8bc62c430592f527e'; TargetHash='ade5dc8f6f448d927f592870f21ab10c9322d6365f02edd5ba5621e0169ad0ad' }
    [pscustomobject]@{ Id='OLP-0139'; Path='content/first-order-logic/introduction/introduction.tex';             SourceBlob='2169aa069ea7464369d29d305bacfffa5d60c5df'; SourceHash='3da46f27a563094a0904eacf23838c601ce3a22b0db9d82cfe33d95d8a507b95'; TargetHash='33bb48042dd995541ab6c9af94a8841509eff5d8762f12806e3be48058e30b51' }
    [pscustomobject]@{ Id='OLP-0140'; Path='content/first-order-logic/introduction/first-order-logic.tex';          SourceBlob='2d9e147ca41a3d27e24ca2f2fb80ac576dbd1508'; SourceHash='32887943e2083de8ae7402ced896b1e5c85beee1c52df199a5dce311cdc91627'; TargetHash='cd2885e22eaae61e9845f7ec1ca633d9986747d7a8d8116d0004f7a801b24f9f' }
    [pscustomobject]@{ Id='OLP-0141'; Path='content/first-order-logic/introduction/syntax.tex';                     SourceBlob='d38452a7463d5109384e1332367d18e435a1cfb9'; SourceHash='91d8aaea25b2d821af6aa8016f994b2e0abbf5cd2debdef7354409fa8ce767d8'; TargetHash='9ebdcdd3dc75ba37a682c7c8d552de99dfdfb01424efd925ffc57418b601cbef' }
    [pscustomobject]@{ Id='OLP-0142'; Path='content/first-order-logic/introduction/formulas.tex';                   SourceBlob='6ca80552927ac8fec0756432a3041f0828ad142f'; SourceHash='43b36e58c2cf5bd1c22018eb0a758d0ed31ab304dc1b3d5532358f6e9703a7c1'; TargetHash='5bc0c31ea892079192e4731553ed72a8ae7bf2ab610009eaeadef211f025d778' }
    [pscustomobject]@{ Id='OLP-0143'; Path='content/first-order-logic/introduction/satisfaction.tex';               SourceBlob='3ec75b194eaeb7f45103e1457522d4683e53ad03'; SourceHash='7131c06390c685ff0af79611754cf0b98a22dd8a77256a332c84bf39e2f5cc0a'; TargetHash='664c8c388c97d55cc53b24b4098845b1c480a583b5ef866def8db5cae033ec3d' }
    [pscustomobject]@{ Id='OLP-0144'; Path='content/first-order-logic/introduction/sentences.tex';                  SourceBlob='bb3bb90b9282f3f0f9860a1f0f19bce3f807f4ff'; SourceHash='e02b1d562648ce99867d653622b5c8bcb4cd4eeb9e02d335fa59715e193b3cc9'; TargetHash='523ffd6824e13fdca509c2f7553a929fcd8caafab82e38bcdb36a55e44e8ae0d' }
    [pscustomobject]@{ Id='OLP-0145'; Path='content/first-order-logic/introduction/semantic-notions.tex';           SourceBlob='9bb86bc80c2aa2189c33f7705a0ce152307a8ef4'; SourceHash='5b59ab9c84aad202080a9a834229b1310ba7fb18cbc6891024c072723b9fbadd'; TargetHash='238a472a82116b9f8a3db47641eb40ea1fbbf14b14a1f8aad8fdf7de2f708822' }
    [pscustomobject]@{ Id='OLP-0146'; Path='content/first-order-logic/introduction/substitution.tex';              SourceBlob='bbae5e7735b83b9eec43cd8622152bf163fbf8c3'; SourceHash='d1e27e94b43fda8329176530bfa9528c859d444123257a7408d5a979151b8941'; TargetHash='60847d1c66e6df26da77ecb4ed98f7c93644faa40e2d1d071eff26615f518a93' }
    [pscustomobject]@{ Id='OLP-0147'; Path='content/first-order-logic/introduction/models-theories.tex';           SourceBlob='f2927425bffd59c4c0983946b4ab22b84a7b33a1'; SourceHash='9207639415c1946c70ead4464cefaec9ed2972f35121e88272980b6c9a076ca8'; TargetHash='145ecdfe8c08b9989d767ce6beec6ea12557b354b31dc64a72d7bcb7a74bc597' }
    [pscustomobject]@{ Id='OLP-0148'; Path='content/first-order-logic/introduction/soundness-completeness.tex';     SourceBlob='98c661082ac6dd6a337ddafa20265fe9859eca0d'; SourceHash='49f9a2fb437d680d3e796d72b46d1bc1c5a60c58e3e13ac2e19e6bac6976336e'; TargetHash='09bc476393eb90d09d6df8e739f79bdeab1c06f9340aca2f92f5980fb859e7ad' }
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
    tag_keys = 0
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
        'content/first-order-logic/introduction/first-order-logic.tex' {
            $result = Replace-Exact $result `
                '$\lforall[x][(!A(x) \lif !B(x)),' `
                '$\lforall[x][(!A(x) \lif !B(x))],' 1 'fol-introduction/combined-entailment-scope'
            $result = Replace-Exact $result `
                '\Entails \lexists[x][!B(x)]]$' `
                '\Entails \lexists[x][!B(x)]$' 1 'fol-introduction/combined-entailment-trailing-bracket'
            $result = Replace-Exact $result `
                '$\lforall[x][(!A(x) \lif !B(x))$' `
                '$\lforall[x][(!A(x) \lif !B(x))]$' 1 'fol-introduction/universal-premise-scope-inline'
            $oldSplitUniversal = '$\lforall[x][(!A(x)' + "`n" + '\lif !B(x))$'
            $newSplitUniversal = '$\lforall[x][(!A(x)' + "`n" + '\lif !B(x))]$'
            $result = Replace-Exact $result $oldSplitUniversal $newSplitUniversal 1 `
                'fol-introduction/universal-premise-scope-split'
            $result = Replace-Exact $result `
                '$\lexists[x][!B(x)]]$' `
                '$\lexists[x][!B(x)]$' 2 'fol-introduction/existential-trailing-bracket'
        }
        'content/first-order-logic/introduction/satisfaction.tex' {
            $result = Replace-Exact $result `
                'the !!{constant}s can have more than one place' `
                'the !!{predicate}s can have more than one place' 1 'satisfaction/predicate-arity'
            $oldDomainValues = '(in our example, to one' + "`n" + 'of $1$, $2$, or~$3$)'
            $newDomainValues = '(in our example, to one' + "`n" + 'of $0$, $1$, or~$2$)'
            $result = Replace-Exact $result $oldDomainValues $newDomainValues 1 'satisfaction/domain-values'
        }
        'content/first-order-logic/introduction/substitution.tex' {
            $oldAtomDelimiter = '$\lforall[\Obj' + "`n" + 'v_0][\Atom{\Obj P}]{\Obj v_0}$'
            $newAtomDelimiter = '$\lforall[\Obj' + "`n" + 'v_0][\Atom{\Obj P}{\Obj v_0}]$'
            $result = Replace-Exact $result $oldAtomDelimiter $newAtomDelimiter 1 'substitution/atom-delimiter'
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
    [int]$_.stable_order -ge 138 -and [int]$_.stable_order -le 148
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
    $sourceRelative = $unit.Path
    $targetRelative = "locale/id/$sourceRelative"
    $sourcePath = Join-Path $repoRoot ($sourceRelative -replace '/', '\')
    $targetPath = Join-Path $repoRoot ($targetRelative -replace '/', '\')
    $row = $manifestBatch[$unitIndex]

    Assert-Exact (
        $row.closure_id -ceq $unit.Id -and
        [int]$row.stable_order -eq (138 + $unitIndex) -and
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
    $targetChapterIds = @([regex]::Matches($target, '\\olchapter(?!\[)'))
    Assert-Exact ($sourceChapterIds.Count -eq $targetChapterIds.Count) "$($unit.Id)/chapter-ids" "count=$($targetChapterIds.Count)"
    $totals.chapter_ids += $targetChapterIds.Count

    $sourceDigestRecords.Add("$($unit.Id)|$($unit.SourceBlob)|$($unit.SourceHash)|$sourceRelative")
    $targetDigestRecords.Add("$($unit.Id)|$($unit.TargetHash)|$targetRelative")
}

$declaredCorrections = @(
    [pscustomobject]@{ Name='fol-introduction/combined-entailment-scope'; Path='content/first-order-logic/introduction/first-order-logic.tex'; SourceRegex='\$\\lforall\[x\]\[\(!A\(x\) \\lif !B\(x\)\)\s*,\s*\\lexists'; SourceCount=1; TargetRegex='\$\\lforall\[x\]\[\(!A\(x\) \\lif !B\(x\)\)\]\s*,\s*\\lexists'; TargetCount=1; BadTargetRegex='\$\\lforall\[x\]\[\(!A\(x\) \\lif !B\(x\)\)\s*,\s*\\lexists' }
    [pscustomobject]@{ Name='fol-introduction/combined-entailment-trailing-bracket'; Path='content/first-order-logic/introduction/first-order-logic.tex'; SourceRegex='\\Entails \\lexists\[x\]\[!B\(x\)\]\]\$'; SourceCount=1; TargetRegex='\\Entails \\lexists\[x\]\[!B\(x\)\]\$'; TargetCount=1; BadTargetRegex='\\Entails \\lexists\[x\]\[!B\(x\)\]\]\$' }
    [pscustomobject]@{ Name='fol-introduction/universal-premise-scope'; Path='content/first-order-logic/introduction/first-order-logic.tex'; SourceRegex='\$\\lforall\[x\]\[\(!A\(x\)\s+\\lif !B\(x\)\)\$'; SourceCount=2; TargetRegex='\$\\lforall\[x\]\[\(!A\(x\)\s*\\lif !B\(x\)\)\]\$'; TargetCount=4; BadTargetRegex='\$\\lforall\[x\]\[\(!A\(x\)\s+\\lif !B\(x\)\)\$' }
    [pscustomobject]@{ Name='fol-introduction/existential-trailing-bracket'; Path='content/first-order-logic/introduction/first-order-logic.tex'; SourceRegex='\$\\lexists\[x\]\[!B\(x\)\]\]\$'; SourceCount=2; TargetRegex='\$\\lexists\[x\]\[!B\(x\)\]\$'; TargetCount=4; BadTargetRegex='\$\\lexists\[x\]\[!B\(x\)\]\]\$' }
    [pscustomobject]@{ Name='satisfaction/predicate-arity'; Path='content/first-order-logic/introduction/satisfaction.tex'; SourceRegex='the !!\{constant\}s can have more than one place'; SourceCount=1; TargetRegex='!!\{predicate\}s dapat memiliki lebih dari\s+satu tempat'; TargetCount=1; BadTargetRegex='!!\{constant\}s dapat memiliki lebih dari\s+satu tempat' }
    [pscustomobject]@{ Name='satisfaction/domain-values'; Path='content/first-order-logic/introduction/satisfaction.tex'; SourceRegex='one\s+of \$1\$, \$2\$, or~\$3\$'; SourceCount=1; TargetRegex='salah satu dari \$0\$, \$1\$, atau~\$2\$'; TargetCount=1; BadTargetRegex='salah satu dari \$1\$, \$2\$, atau~\$3\$' }
    [pscustomobject]@{ Name='substitution/atom-delimiter'; Path='content/first-order-logic/introduction/substitution.tex'; SourceRegex='\\lforall\[\\Obj\s+v_0\]\[\\Atom\{\\Obj P\}\]\{\\Obj v_0\}'; SourceCount=1; TargetRegex='\\lforall\[\\Obj v_0\]\[\\Atom\{\\Obj P\}\{\\Obj v_0\}\]'; TargetCount=1; BadTargetRegex='\\lforall\[\\Obj\s+v_0\]\[\\Atom\{\\Obj P\}\]\{\\Obj v_0\}' }
)

foreach ($correction in $declaredCorrections) {
    Assert-Correction $correction $rawSource $rawTarget
}

# Bind the post-review Indonesian fixes that do not represent upstream-source
# mathematical corrections and therefore are not exceptions to the replay.
Assert-TargetReview $rawTarget 'content/first-order-logic/introduction/introduction.tex' `
    'chapter-command-no-invalid-locale-option' '\\olchapter\{fol\}\{int\}\{Pengantar Logika Orde Pertama\}' 1
Assert-TargetReview $rawTarget 'content/first-order-logic/introduction/introduction.tex' `
    'chapter-command-invalid-locale-option-absent' '\\olchapter\[id\]' 0
Assert-TargetReview $rawTarget 'content/first-order-logic/introduction/first-order-logic.tex' `
    'semantic-validity-register' 'Argumen itu\s+jelas valid' 1
Assert-TargetReview $rawTarget 'content/first-order-logic/introduction/satisfaction.tex' `
    'variable-referent-restored' 'Kita hanya akan\s+menggunakan variabel-variabel yang kita perlukan' 1
Assert-TargetReview $rawTarget 'content/first-order-logic/introduction/syntax.tex' `
    'nbsp-syntax-disjunction' 'atau~\$\\lexists' 1
Assert-TargetReview $rawTarget 'content/first-order-logic/introduction/models-theories.tex' `
    'nbsp-two-place-predicate' 'dua-tempat~\$\\Obj P\$' 1
Assert-TargetReview $rawTarget 'content/first-order-logic/introduction/models-theories.tex' `
    'nbsp-in-Gamma' 'dalam~\$\\Gamma\$' 2
Assert-TargetReview $rawTarget 'content/first-order-logic/introduction/models-theories.tex' `
    'nbsp-only-predicate' 'hanya~\$\\Obj P\$' 1
Assert-TargetReview $rawTarget 'content/first-order-logic/introduction/soundness-completeness.tex' `
    'nbsp-set-Gamma' 'himpunan~\$\\Gamma\$' 1

$allTarget = ($units | ForEach-Object { $rawTarget[$_.Path] }) -join "`n"
Assert-Exact (-not [regex]::IsMatch($allTarget, '\\olfileid(?!\[id\])')) `
    'batch/all-file-identifiers-id'
Assert-Exact (-not [regex]::IsMatch($rawTarget['content/first-order-logic/introduction/introduction.tex'], '\\olchapter\[id\]')) `
    'batch/chapter-command-not-locale-overloaded'

# Preserved upstream findings are required to remain visible until an upstream
# source decision exists; the Indonesian target does not silently rewrite them.
Assert-TargetReview $rawTarget 'content/first-order-logic/introduction/models-theories.tex' `
    'preserved/ambiguous-characterization-pronouns' 'kalimat-kalimat\s+itu benar tepat di dalam struktur-struktur tersebut' 1
Assert-TargetReview $rawTarget 'content/first-order-logic/introduction/models-theories.tex' `
    'preserved/nonempty-preorder-scope' 'model-model \$\\Gamma\$ tepat merupakan semua praorder' 1
Assert-TargetReview $rawTarget 'content/first-order-logic/introduction/models-theories.tex' `
    'preserved/property-entailment-type' 'Setiap sifat semua\s+praorder.*diakibatkan oleh kedua !!\{sentence\}s dalam~\$\\Gamma\$, dan sebaliknya' 1
Assert-TargetReview $rawTarget 'content/first-order-logic/introduction/models-theories.tex' `
    'preserved/finite-cardinality-needs-identity' 'memuat tepat \$n\$~!!\{element\}s' 1
Assert-TargetReview $rawTarget 'content/first-order-logic/introduction/models-theories.tex' `
    'preserved/infinitude-needs-identity' 'menyatakan bahwa !!\{domain\} bersifat tak\s+hingga' 1
Assert-TargetReview $rawTarget 'content/first-order-logic/introduction/soundness-completeness.tex' `
    'preserved/all-derivation-systems-same-relation' 'tetapi semuanya mendefinisikan relasi !!\{derivability\} yang sama' 1
Assert-TargetReview $rawTarget 'content/first-order-logic/introduction/soundness-completeness.tex' `
    'preserved/unquantified-contradiction-formula' 'tidak\s+dapat membuktikan \$!A \\land \\lnot !A\$ dari \$\\Gamma\$ menjamin' 1

Assert-Exact ($sourceCorrectionClasses -eq 7) 'batch/source-correction-class-count' 'count=7'
Assert-Exact ($sourceCorrectionOccurrences -eq 9) 'batch/source-correction-occurrence-count' 'count=9'
Assert-Exact ($targetCorrectionAssertions -eq 7) 'batch/target-correction-assertion-count' 'count=7'
Assert-Exact ($targetReviewAssertions -eq 16) 'batch/target-review-assertion-count' 'count=16'

# These values are filled after the first successful independent replay and
# then freeze the aggregate so a weakened parser cannot pass by symmetry.
$expectedTotals = [ordered]@{
    commands = 633
    environments = 40
    semantic_tokens = 219
    labels = 4
    references = 7
    citations = 1
    assets = 0
    imports = 20
    tag_keys = 8
    math_skeletons = 333
    math_environments = 1
    localized_file_ids = 9
    chapter_ids = 1
}
foreach ($entry in $expectedTotals.GetEnumerator()) {
    if ($entry.Value -ge 0) {
        Assert-Exact ($totals[$entry.Key] -eq $entry.Value) "batch/frozen-total-$($entry.Key)" "count=$($entry.Value)"
    }
}

$sourceSetDigest = Get-TextDigest @($sourceDigestRecords)
$targetSetDigest = Get-TextDigest @($targetDigestRecords)
foreach ($unit in $units) { Write-Output "TARGET_HASH $($unit.Id) $($unit.Path) $($unit.TargetHash)" }
Write-Output ("STRUCTURAL_TOTALS commands={0} environments={1} semantic_tokens={2} labels={3} references={4} citations={5} assets={6} imports={7} tag_keys={8} math_skeletons={9} math_environments={10} localized_file_ids={11} chapter_ids={12}" -f `
    $totals.commands, $totals.environments, $totals.semantic_tokens, $totals.labels,
    $totals.references, $totals.citations, $totals.assets, $totals.imports,
    $totals.tag_keys, $totals.math_skeletons, $totals.math_environments,
    $totals.localized_file_ids, $totals.chapter_ids)
Write-Output "CORRECTION_TOTALS classes=$sourceCorrectionClasses source_occurrences=$sourceCorrectionOccurrences target_assertions=$targetCorrectionAssertions target_review_assertions=$targetReviewAssertions"
Write-Output "BINDING_DIGESTS source_set_sha256=$sourceSetDigest target_set_sha256=$targetSetDigest"
Write-Output "FOL_INTRODUCTION_BATCH_REPLAY_OK files=$($units.Count) checks=$checks upstream=$expectedCommit closure=OLP-0138..OLP-0148"
