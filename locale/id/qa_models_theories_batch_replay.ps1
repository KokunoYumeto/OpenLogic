$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$localeRoot = $PSScriptRoot
$repoRoot = [IO.Path]::GetFullPath((Join-Path $localeRoot '..\..'))
$controlRoot = [IO.Path]::GetFullPath((Join-Path $repoRoot '..\_control'))
$manifestPath = Join-Path $controlRoot 'OPENLOGIC_CLOSURE_MANIFEST_20260812.csv'
$expectedCommit = '9620cc73f9c8e0ad003c514a5d3748f29611c4c0'
$expectedDocCommit = 'b46686df0e06f302a7b75a74b379c802f7c7b565'
$expectedTokenDocBlob = 'e9b3c38ee123574e44e56a4145a67d714cc234aa'
$expectedTokenDocHash = '3e5601e5711c74f3cc22f2fe08365d05b8e87754160e3f0f554edfc49bc86a80'

# Each row binds an immutable source object, the independently replayed
# source/worktree hash in the 722-row closure manifest, and the final reviewed
# Indonesian bytes. Any drift fails closed.
$units = @(
    [pscustomobject]@{ Id='OLP-0167'; Path='content/first-order-logic/models-theories/models-theories.tex';                SourceBlob='f253e3a896a8747ba5aa3bae33f57e6f6cb715e1'; SourceHash='a3a51cfc65725adf5e09f41af5e24114847757effad8d2c49827bb427e16da6f'; TargetHash='767505629b7ced0e2513dea1945a82e67e12b48a3172e4feff56aa68ac1d3607' }
    [pscustomobject]@{ Id='OLP-0168'; Path='content/first-order-logic/models-theories/introduction.tex';                   SourceBlob='fb3bf885473c223d772f118d2be217c2e062722f'; SourceHash='56518e9cb660f5393a035d369656023c1e2301db8eb220c642131a14a5cdc8d8'; TargetHash='3a1079a9fc045adf062c20d74151d16f234665daaf994985281563da438076f1' }
    [pscustomobject]@{ Id='OLP-0169'; Path='content/first-order-logic/models-theories/expressing-props-of-structures.tex'; SourceBlob='8d3effa95471011f651b4087da4ca796009f7947'; SourceHash='939bbd9f240291eefaf1926db84c710e635642e1c0b083d6bb8fd7c62b302db0'; TargetHash='3d45a9dfcfe40490fcd258b4f2ec9e58326cdc78d8564e6637a85b2844ea9c0c' }
    [pscustomobject]@{ Id='OLP-0170'; Path='content/first-order-logic/models-theories/theories.tex';                       SourceBlob='12c303d64912fd547e64f7e2ff4f219510442143'; SourceHash='0d47cc25cb7555009033f6dd8131beddfe7a36d514989154d241d98c3ae92536'; TargetHash='055f4af3528c4dc68351f124507d89ba120a010717302e05429e0dbd890a9350' }
    [pscustomobject]@{ Id='OLP-0171'; Path='content/first-order-logic/models-theories/expressing-relations.tex';           SourceBlob='4f4c0a3b30ada41649576eb8b17a2206cfe3ddb7'; SourceHash='4463b194f95a1e7649f0ee833e2851273e78e760d9db32f67f925c8d551daa7d'; TargetHash='300f6d199e4750c6d1aaab65c0db9c014c5cf6476807a9ed586c67412ca94519' }
    [pscustomobject]@{ Id='OLP-0172'; Path='content/first-order-logic/models-theories/set-theory.tex';                     SourceBlob='b04c16a01f2ab5cab809f2aa3189b74f4059f6bd'; SourceHash='c252116bc14449400e362e11e002d865f58e59177215cab085ceaec7ae9d2aa3'; TargetHash='be3c755f6c74775c117c7f68c07c74dbd37202b23b08e72170cf03a0d0c69c64' }
    [pscustomobject]@{ Id='OLP-0173'; Path='content/first-order-logic/models-theories/size-of-structures.tex';             SourceBlob='d9f2315b15aeb8396e81ac6e5ea0adae5cf28b7f'; SourceHash='b63fc24a59388785180fe06e738b2b2e0e61c05896050bbfb1959fd6ddcf0060'; TargetHash='fd62fecca24d670d2d318f11b3e08eac87aa6b1fdd6367c2b6963de02c774cff' }
)

$checks = 0
$normalizationMatches = 0
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
    uppercase_tokens = 0
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

function Invoke-GitBytes([string]$WorkingDirectory, [string[]]$Arguments) {
    $start = [Diagnostics.ProcessStartInfo]::new()
    $start.FileName = 'git'
    $start.WorkingDirectory = $WorkingDirectory
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

function Assert-RegexCount([string]$Name, [string]$Text, [string]$Pattern, [int]$Expected) {
    $actual = ([regex]::Matches($Text, $Pattern, 'Singleline')).Count
    Assert-Exact ($actual -eq $Expected) $Name "count=$actual"
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

function Replace-RegexExact(
    [string]$Text,
    [string]$Pattern,
    [string]$Replacement,
    [int]$ExpectedCount,
    [string]$Name
) {
    $regex = [regex]::new($Pattern, [Text.RegularExpressions.RegexOptions]::Singleline)
    $actual = $regex.Matches($Text).Count
    if ($actual -ne $ExpectedCount) {
        throw "$Name normalization occurrence mismatch expected=$ExpectedCount actual=$actual"
    }
    $script:normalizationMatches += $actual
    $evaluator = [Text.RegularExpressions.MatchEvaluator]{ param($match) $Replacement }
    return $regex.Replace($Text, $evaluator)
}

function Get-CorrectedSourceForReplay([string]$Path, [string]$Text) {
    $result = Normalize-Newlines $Text
    switch ($Path) {
        'content/first-order-logic/models-theories/theories.tex' {
            $result = Replace-RegexExact $result `
                'is a linear order on a set \$X\$' `
                'is a strict linear order on a set $X$' 1 `
                'theories/strict-linear-order-converse'
        }
        'content/first-order-logic/models-theories/expressing-relations.tex' {
            $result = Replace-RegexExact $result `
                'These theories often only\s+contain a few !!\{predicate\}s as basic symbols, but in the domain they\s+are used to describe often many other relations play an important\s+role\.' `
                'These theories often contain only a few !!{predicate}s as basic symbols, but in the domains they are used to describe, many other relations often play an important role.' 1 `
                'expressing-relations/malformed-domain-prose'
            $result = Replace-RegexExact $result `
                '\\eq\[\(\\Obj v_1 \+ \{\\Obj v_3\}''\)\]\[v_2\]' `
                '\eq[(\Obj v_1 + {\Obj v_3}'')][\Obj v_2]' 1 `
                'expressing-relations/object-language-v2'
        }
        'content/first-order-logic/models-theories/set-theory.tex' {
            $result = Replace-RegexExact $result `
                '\\lif y = y''\)\]\]\)\)' `
                '\lif y = y'')]])))' 1 `
                'set-theory/function-definition-outer-parenthesis'
            $result = Replace-RegexExact $result `
                '!A\(x\)\)\]\]\]\.' `
                '!A(x)))]]].' 1 `
                'set-theory/separation-outer-parenthesis'
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
    $items = [Collections.Generic.List[object]]::new()
    foreach ($match in [regex]::Matches($Text, '(?<!\\)\$(.*?)(?<!\\)\$', 'Singleline')) {
        $items.Add([pscustomobject]@{ Index=$match.Index; Value=('INLINE:' + (Normalize-Math $match.Value)) })
    }
    foreach ($match in [regex]::Matches($Text, '\\\[(.*?)\\\]', 'Singleline')) {
        $items.Add([pscustomobject]@{ Index=$match.Index; Value=('DISPLAY:' + (Normalize-Math $match.Value)) })
    }
    return @($items | Sort-Object Index | ForEach-Object { $_.Value })
}

function Get-MathEnvironmentStructures([string]$Text) {
    $items = [Collections.Generic.List[object]]::new()
    foreach ($environment in @('align', 'align*', 'multline', 'multline*', 'equation', 'equation*', 'aligned', 'cases')) {
        $escaped = [regex]::Escape($environment)
        $pattern = "\\begin\{$escaped\}(?:\[[^\]]*\])?(?<body>.*?)\\end\{$escaped\}"
        foreach ($match in [regex]::Matches($Text, $pattern, 'Singleline')) {
            $body = Replace-ProseArgument $match.Groups['body'].Value 'text'
            $body = Replace-ProseArgument $body 'textrm'
            $body = Replace-ProseArgument $body 'intertext'
            $items.Add([pscustomobject]@{
                Index = $match.Index
                Value = $environment + ':' + (Normalize-Math $body)
            })
        }
    }
    return @($items | Sort-Object Index | ForEach-Object { $_.Value })
}

function Get-CommandSequence([string]$Text) {
    return @(Get-Sequence $Text '(?<value>\\[A-Za-z@]+|\\.)')
}

function Get-SemanticTokenNames([string]$Text) {
    return @([regex]::Matches($Text, '!!(?:\^)?(?:a|A)?\{(?<value>[^{}]+)\}(?:s|d)?', 'Singleline') |
        ForEach-Object { [regex]::Replace($_.Groups['value'].Value, '\s+', ' ') } | Sort-Object)
}

function Remove-NonReaderSurface([string]$Text) {
    $result = Remove-TexComments $Text
    $result = [regex]::Replace($result, '\\\[.*?\\\]', '', 'Singleline')
    $result = [regex]::Replace($result, '(?<!\\)\$.*?(?<!\\)\$', '', 'Singleline')
    $result = [regex]::Replace($result, '!!(?:\^)?(?:a|A)?\{[^{}]+\}(?:s|d)?', '')
    return $result
}

function Assert-CorrectionClass(
    [hashtable]$RawSource,
    [hashtable]$RawTarget,
    [string]$Path,
    [string]$Name,
    [string]$SourcePattern,
    [int]$SourceCount,
    [string]$TargetPattern,
    [int]$TargetCount,
    [int]$Occurrences
) {
    Assert-RegexCount "correction-source/$Name" $RawSource[$Path] $SourcePattern $SourceCount
    Assert-RegexCount "correction-target/$Name" $RawTarget[$Path] $TargetPattern $TargetCount
    $script:sourceCorrectionClasses++
    $script:sourceCorrectionOccurrences += $Occurrences
    $script:targetCorrectionAssertions++
}

function Assert-TargetReview(
    [hashtable]$RawTarget,
    [string]$Path,
    [string]$Name,
    [string]$AcceptedPattern,
    [string[]]$RejectedPatterns
) {
    Assert-RegexCount "target-review/$Name/accepted" $RawTarget[$Path] $AcceptedPattern 1
    foreach ($rejected in $RejectedPatterns) {
        Assert-RegexCount "target-review/$Name/rejected" $RawTarget[$Path] $rejected 0
    }
    $script:targetReviewAssertions++
}

$commitType = @(& git -C $repoRoot cat-file -t $expectedCommit 2>$null)
Assert-Exact (($LASTEXITCODE -eq 0) -and $commitType.Count -eq 1 -and $commitType[0] -ceq 'commit') `
    'frozen-source-commit-object' $expectedCommit
Assert-Exact (Test-Path -LiteralPath $manifestPath) 'closure-manifest-present' $manifestPath

# The documentation submodule is itself frozen by the parent commit. Its
# Tokenized-Text specification is the primary evidence that !!^{...} and
# !!^{...}s are valid sentence-initial uppercase token forms.
$docTree = @(& git -C $repoRoot ls-tree $expectedCommit doc 2>$null)
Assert-Exact (
    $LASTEXITCODE -eq 0 -and $docTree.Count -eq 1 -and
    $docTree[0] -ceq "160000 commit $expectedDocCommit`t" + 'doc'
) 'token-doc/submodule-gitlink' $expectedDocCommit
$docRoot = Join-Path $repoRoot 'doc'
$tokenDocPath = Join-Path $docRoot 'Tokenized-Text.md'
Assert-Exact (Test-Path -LiteralPath $tokenDocPath) 'token-doc/present' $tokenDocPath
$docHead = @(& git -C $docRoot rev-parse HEAD 2>$null)
Assert-Exact ($LASTEXITCODE -eq 0 -and $docHead.Count -eq 1 -and $docHead[0] -ceq $expectedDocCommit) `
    'token-doc/submodule-head' $expectedDocCommit
$tokenDocBlob = @(& git -C $docRoot rev-parse 'HEAD:Tokenized-Text.md' 2>$null)
Assert-Exact ($LASTEXITCODE -eq 0 -and $tokenDocBlob.Count -eq 1 -and $tokenDocBlob[0] -ceq $expectedTokenDocBlob) `
    'token-doc/blob' $expectedTokenDocBlob
Assert-Exact ((Get-Sha256 $tokenDocPath) -ceq $expectedTokenDocHash) `
    'token-doc/worktree-hash' $expectedTokenDocHash
$tokenDoc = [IO.File]::ReadAllText($tokenDocPath)
Assert-RegexCount 'token-doc/uppercase-singular-grammar' $tokenDoc `
    ([regex]::Escape('use !!^{_token_}')) 1
Assert-RegexCount 'token-doc/uppercase-plural-grammar' $tokenDoc `
    ([regex]::Escape('!!^{_token_}s')) 1

$manifest = Import-Csv -LiteralPath $manifestPath
$manifestBatch = @($manifest | Where-Object {
    [int]$_.stable_order -ge 167 -and [int]$_.stable_order -le 173
} | Sort-Object { [int]$_.stable_order })
Assert-Exact ($manifestBatch.Count -eq $units.Count) 'manifest-batch-count' "count=$($units.Count)"
Assert-Sequence 'manifest/ordered-closure-ids' @($units.Id) @($manifestBatch.closure_id)

$literalPatterns = [ordered]@{
    environments = '(?<value>\\(?:begin|end)\{[^{}]+\})'
    labels = '(?<value>\\ollabel\{[^{}]+\})'
    references = '(?<value>\\(?:olref|Olref)(?:\[[^\]]*\]){0,3}\{[^{}]+\}|\\(?:cref|Cref)\{[^{}]+\})'
    citations = '(?<value>\\cite[a-zA-Z]*\{[^{}]+\})'
    assets = '(?<value>\\olasset(?:\[[^\]]*\])?\{[^{}]+\})'
    imports = '(?<value>\\olimport\*?(?:\[[^\]]*\])?\{[^{}]+\})'
    tagged_items = '(?<value>\\tagitem\{[^{}]+\}|\\tagprob\{[^{}]+\}|\\tagendprob\b)'
    tag_conditionals = '(?<value>\\iftag\{[^{}]+\})'
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
        [int]$row.stable_order -eq (167 + $unitIndex) -and
        $row.source_commit -ceq $expectedCommit -and
        $row.source_path -ceq $sourceRelative -and
        $row.source_sha256.ToLowerInvariant() -ceq $unit.SourceHash -and
        $row.target_path -ceq $targetRelative -and
        $row.closure_included -ceq 'true' -and
        $row.canonical_reader_reachable -ceq 'true'
    ) "$($unit.Id)/manifest-binding"

    Assert-Exact (Test-Path -LiteralPath $sourcePath) "$($unit.Id)/source-worktree-present"
    Assert-Exact (Test-Path -LiteralPath $targetPath) "$($unit.Id)/target-present"
    Assert-Exact ((Get-Sha256 $sourcePath) -ceq $unit.SourceHash) `
        "$($unit.Id)/source-worktree-hash" $unit.SourceHash
    $resolvedBlob = @(& git -C $repoRoot rev-parse --verify "$expectedCommit`:$sourceRelative" 2>$null)
    Assert-Exact (
        $LASTEXITCODE -eq 0 -and $resolvedBlob.Count -eq 1 -and $resolvedBlob[0] -ceq $unit.SourceBlob
    ) "$($unit.Id)/source-git-object" $unit.SourceBlob
    $blobBytes = Invoke-GitBytes $repoRoot @('cat-file', 'blob', $unit.SourceBlob)
    $blobText = Normalize-Newlines ([Text.Encoding]::UTF8.GetString($blobBytes))
    $worktreeText = Normalize-Newlines ([IO.File]::ReadAllText($sourcePath))
    Assert-Exact ($blobText -ceq $worktreeText) `
        "$($unit.Id)/source-git-worktree-content-binding" 'newline-normalized=true'
    Assert-Exact ((Get-Sha256 $targetPath) -ceq $unit.TargetHash) "$($unit.Id)/target-hash" $unit.TargetHash

    $sourceTextRaw = $blobText
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
    Assert-Exact ($sourceFileIds.Count -eq $targetFileIds.Count) `
        "$($unit.Id)/localized-file-ids" "count=$($targetFileIds.Count)"
    $totals.localized_file_ids += $targetFileIds.Count

    $sourceChapterIds = @([regex]::Matches($source, '\\olchapter(?:\[[^\]]+\])?'))
    $targetChapterIds = @([regex]::Matches($target, '\\olchapter(?!\[)'))
    Assert-Exact ($sourceChapterIds.Count -eq $targetChapterIds.Count) `
        "$($unit.Id)/chapter-ids" "count=$($targetChapterIds.Count)"
    $totals.chapter_ids += $targetChapterIds.Count

    $targetUppercase = @([regex]::Matches($target, '!!\^(?:a|A)?\{[^{}\r\n]+\}(?:s|d)?'))
    $totals.uppercase_tokens += $targetUppercase.Count
    $sourceDigestRecords.Add("$($unit.Id)|$($unit.SourceBlob)|$($unit.SourceHash)|$sourceRelative")
    $targetDigestRecords.Add("$($unit.Id)|$($unit.TargetHash)|$targetRelative")
}

# Five and only five source corrections are carried into the Indonesian
# target. Both the frozen source defect and the reviewed target disposition are
# asserted. The corrections are also applied above solely to structural/math
# replay so source and target can be compared without hiding the divergence.
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/models-theories/theories.tex' `
    'theories/strict-linear-order-converse' `
    'if \$R\$\s+is a linear order on a set \$X\$' 1 `
    'jika\s+\$R\$ merupakan urutan linear ketat pada suatu himpunan \$X\$' 1 1
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/models-theories/expressing-relations.tex' `
    'expressing-relations/malformed-domain-prose' `
    'These theories often only\s+contain a few !!\{predicate\}s as basic symbols, but in the domain they\s+are used to describe often many other relations play an important\s+role\.' 1 `
    'Teori\s+semacam itu sering kali hanya memuat sedikit !!\{predicate\}s sebagai simbol\s+dasar, tetapi banyak relasi lain sering berperan penting dalam domain yang\s+hendak dideskripsikan\.' 1 1
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/models-theories/expressing-relations.tex' `
    'expressing-relations/object-language-v2' `
    '\\eq\[\(\\Obj v_1 \+ \{\\Obj v_3\}''\)\]\[v_2\]' 1 `
    '\\eq\[\(\\Obj v_1 \+ \{\\Obj v_3\}''\)\]\[\\Obj v_2\]' 1 1
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/models-theories/set-theory.tex' `
    'set-theory/function-definition-outer-parenthesis' `
    '\\lif y = y''\)\]\]\)\)' 1 `
    '\\lif y = y''\)\]\]\)\)\)' 1 1
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/models-theories/set-theory.tex' `
    'set-theory/separation-outer-parenthesis' `
    '!A\(x\)\)\]\]\]\.' 1 `
    '!A\(x\)\)\)\]\]\]\.' 1 1

# Independent Indonesian wording review: exact accepted bytes and rejected
# earlier alternatives. These do not alter formulas or source semantics.
Assert-TargetReview $rawTarget 'content/first-order-logic/models-theories/models-theories.tex' `
    'chapter-title' '\\olchapter\{fol\}\{mat\}\{Teori dan Model-Modelnya\}' `
    @('\\olchapter\{fol\}\{mat\}\{Teori dan Modelnya\}', '\\olchapter\{fol\}\{mat\}\{Teori-Teori dan Model-Modelnya\}')
Assert-TargetReview $rawTarget 'content/first-order-logic/models-theories/theories.tex' `
    'pure-set-predication' 'Suatu himpunan disebut murni jika' `
    @('Suatu himpunan adalah murni jika')
Assert-TargetReview $rawTarget 'content/first-order-logic/models-theories/theories.tex' `
    'empty-set-counts-as-pure' 'himpunan kosong tergolong murni' `
    @('himpunan kosong dianggap murni')

$allTarget = ($units | ForEach-Object { $rawTarget[$_.Path] }) -join "`n"
$tokenSurface = Remove-TexComments $allTarget
$validTokenPattern = '!!(?:\^)?(?:a|A)?\{[^{}\r\n]+\}(?:s|d)?'
$withoutValidTokens = [regex]::Replace($tokenSurface, $validTokenPattern, '')
Assert-Exact (-not [regex]::IsMatch($withoutValidTokens, '!!')) `
    'batch/all-semantic-token-forms-match-grammar'
$uppercaseSequence = @([regex]::Matches($tokenSurface, '!!\^(?:a|A)?\{[^{}\r\n]+\}(?:s|d)?') |
    ForEach-Object { $_.Value })
Assert-Sequence 'batch/uppercase-token-sequence' `
    @('!!^{sentence}s', '!!^{constant}s', '!!^{formula}', '!!^{formula}s',
      '!!^{sentence}', '!!^{sentence}', '!!^{sentence}') `
    $uppercaseSequence
$withoutValidUppercase = [regex]::Replace($tokenSurface, '!!\^(?:a|A)?\{[^{}\r\n]+\}(?:s|d)?', '')
Assert-Exact (-not [regex]::IsMatch($withoutValidUppercase, '!!\^')) `
    'batch/no-malformed-uppercase-token'
Assert-Exact ($totals.uppercase_tokens -eq 7) 'batch/valid-uppercase-token-count' 'count=7'
Assert-Exact (-not [regex]::IsMatch($allTarget, '\\olfileid(?!\[id\])')) `
    'batch/all-file-identifiers-id'
Assert-Exact (-not [regex]::IsMatch($rawTarget['content/first-order-logic/models-theories/models-theories.tex'], '\\olchapter\[id\]')) `
    'batch/chapter-command-not-locale-overloaded'

$englishPhrases = @(
    'The development of the axiomatic method',
    'The axiomatic method and logic',
    'We can think of an axiomatic theory',
    'It is often useful and important',
    'The theory of strict linear orders',
    'This idea is not just interesting',
    'Find formulas in',
    'Almost all of mathematics',
    'There is no single purely logical sentence',
    'Show that the comprehension principle',
    'There are some properties of structures'
)
$englishResidueHits = 0
foreach ($unit in $units) {
    $readerSurface = Remove-NonReaderSurface $rawTarget[$unit.Path]
    foreach ($phrase in $englishPhrases) {
        $count = ([regex]::Matches(
            $readerSurface,
            [regex]::Escape($phrase),
            [Text.RegularExpressions.RegexOptions]::IgnoreCase
        )).Count
        if ($count -gt 0) { throw "Reader-facing English residue in $($unit.Id): '$phrase' count=$count" }
        $englishResidueHits += $count
    }
}
Assert-Exact ($englishResidueHits -eq 0) 'batch/untranslated-reader-prose' 'hits=0'

Assert-Exact ($normalizationMatches -eq 5) 'batch/structural-normalization-match-count' 'count=5'
Assert-Exact ($sourceCorrectionClasses -eq 5) 'batch/source-correction-class-count' 'count=5'
Assert-Exact ($sourceCorrectionOccurrences -eq 5) 'batch/source-correction-occurrence-count' 'count=5'
Assert-Exact ($targetCorrectionAssertions -eq 5) 'batch/target-correction-assertion-count' 'count=5'
Assert-Exact ($targetReviewAssertions -eq 3) 'batch/target-review-assertion-count' 'count=3'

# Frozen totals prevent parser weakening or symmetric omissions from producing
# a false pass. The uncorrected frozen source contains 916 command tokens; the
# sole valid source-to-target delta is the restored object-language \Obj in
# OLP-0171, after which both corrected source and target contain 917.
$expectedTotals = [ordered]@{
    commands = 917
    environments = 94
    semantic_tokens = 109
    labels = 0
    references = 0
    citations = 0
    assets = 0
    imports = 6
    tagged_items = 0
    tag_conditionals = 0
    math_skeletons = 299
    math_environments = 13
    localized_file_ids = 6
    chapter_ids = 1
    uppercase_tokens = 7
}
foreach ($entry in $expectedTotals.GetEnumerator()) {
    Assert-Exact ($totals[$entry.Key] -eq $entry.Value) `
        "batch/frozen-total-$($entry.Key)" "count=$($entry.Value) actual=$($totals[$entry.Key])"
}

$uncorrectedSourceCommands = 0
foreach ($unit in $units) {
    $uncorrectedSourceCommands += (Get-CommandSequence (Remove-TexComments $rawSource[$unit.Path])).Count
}
Assert-Exact ($uncorrectedSourceCommands -eq 916) 'batch/frozen-uncorrected-source-command-count' 'count=916'
Assert-Exact (($totals.commands - $uncorrectedSourceCommands) -eq 1) `
    'batch/sole-command-delta-restored-Obj' 'delta=1'

$sourceSetDigest = Get-TextDigest @($sourceDigestRecords)
$targetSetDigest = Get-TextDigest @($targetDigestRecords)
foreach ($unit in $units) { Write-Output "TARGET_HASH $($unit.Id) $($unit.Path) $($unit.TargetHash)" }
Write-Output ("STRUCTURAL_TOTALS commands={0} environments={1} semantic_tokens={2} labels={3} references={4} citations={5} assets={6} imports={7} tagged_items={8} tag_conditionals={9} math_skeletons={10} math_environments={11} localized_file_ids={12} chapter_ids={13} uppercase_tokens={14}" -f `
    $totals.commands, $totals.environments, $totals.semantic_tokens, $totals.labels,
    $totals.references, $totals.citations, $totals.assets, $totals.imports,
    $totals.tagged_items, $totals.tag_conditionals, $totals.math_skeletons,
    $totals.math_environments, $totals.localized_file_ids, $totals.chapter_ids,
    $totals.uppercase_tokens)
Write-Output "CORRECTION_TOTALS source_classes=$sourceCorrectionClasses source_occurrences=$sourceCorrectionOccurrences structural_normalizations=$normalizationMatches target_assertions=$targetCorrectionAssertions target_review_assertions=$targetReviewAssertions uppercase_false_findings_retracted=7"
Write-Output "BINDING_DIGESTS source_set_sha256=$sourceSetDigest target_set_sha256=$targetSetDigest"
Write-Output "MODELS_THEORIES_BATCH_REPLAY_OK files=$($units.Count) checks=$checks upstream=$expectedCommit closure=OLP-0167..OLP-0173"
