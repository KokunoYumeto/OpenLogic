$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$localeRoot = $PSScriptRoot
$repoRoot = [IO.Path]::GetFullPath((Join-Path $localeRoot '..\..'))
$controlRoot = [IO.Path]::GetFullPath((Join-Path $repoRoot '..\_control'))
$manifestPath = Join-Path $controlRoot 'OPENLOGIC_CLOSURE_MANIFEST_20260812.csv'
$configPath = Join-Path $localeRoot 'open-logic-config.sty'
$expectedCommit = '9620cc73f9c8e0ad003c514a5d3748f29611c4c0'
$expectedConfigHash = '84b09e09ccfa1e03f45ef8cf0de20a3525f9c196317ee4f4a675ab27f1f0cbdd'
$expectedManifestBindingDigest = 'df54d88e2e8791c10ae2023e7dda332c635aa4a337049f8e8338503866532485'
$expectedTargetBindingDigest = '5b8ce0d5fb8495535cdd21ae6dab0a26346b0562d09590de23a4e3610de368f3'
$expectedStructuralDigest = 'c67d345d85a5a185ce1de024498941a754c468354ec0d1b04dbc28c4ab7989b5'
$expectedReviewDigest = 'bbdb9fae78030ad024568be4152e593c9e5720009052bc85bffcee24e6909b94'

$targetBindings = @'
Id,TargetHash,TargetBytes
OLP-0252,80c4ddd9440613e41ded07a6cfcc9b7d709886ed22a9567cbc2997201e309bb6,261
OLP-0253,117aa24ef075838ae0bc97fbf18c7d12bef2444f56ec5721c6d92a5f8b75f538,496
OLP-0254,f0fc9bead6ce606033ba05d23545e1fff227b825b1e23f775f3e92f1556ecce6,7051
OLP-0255,f53b4c95ec85a1f40109e23e8bbb75646546e77daf5aeae3cb0d011ca2a240c0,13115
OLP-0256,3f3a3700eee9ef6b73907e4035898e4bbf941efd7d7683a5c373bb3d5ba114d9,2402
OLP-0257,2abc2e83168c673da1b9a735d4e01f716c45201e9015743cc4beb80a69025a4a,4415
OLP-0258,b588f924d26c4a6eedc4ce886312b34f9708d6a96db9dc786813e948068a8635,11044
OLP-0259,89c236dbeff826699499b423ced8befae44d7e7d1bbffdaa5a1b5d59dd07afbb,3255
OLP-0260,fbbb656fa67e4377ae974c13956eaa4cd35938b6a3cfadf81053d5fb70960fc7,4286
OLP-0261,9d022fd29ed78d54e1d0cd1ccf16421f400cd6bee4249c7fe27d67c9c8582630,8650
OLP-0262,4613bcb1ea951da2fa2fb539a654691459ffd3f669495e2a6e8772e233cae8ce,4908
OLP-0263,93ee8c10196cb8cff19cee1613189e10811d1c855448767b2c3663ded3c2ef7a,2210
OLP-0264,612f65f9a2f04ed147f93f197ae44f38b222755a2661d99b5e5ceb656b1ce7ee,460
OLP-0265,54f1c6a8dfe344116bb41e30fbe19cdb459617550c0a291ef4685ca9b3b0ac33,5687
OLP-0266,fb11c534b017e9c6cb4b3ba3722fde0a82b7adce5383466147b8c5bf58f4e338,7493
OLP-0267,0ada2145660d9194d2a5314a93dde6eaf909fce841f9159ccd5367c89b3f56fb,7363
OLP-0268,f6b945b7bc25ed63d6c5e711bf2464cf4fb27b5bff73f0d8facef234b642ff8c,6588
OLP-0269,0996246d4a9a39a8dda9f1d08db9ca1cc6e364ce51871c3135d4041bc65a87e4,2539
OLP-0270,93c7d554d5241fd42bca8f748d83eb81d82f4037021930392e2d4e54040103d3,8390
OLP-0271,212dc477c735aff0267431a8e61673c89a5ce646ff43d3feaf22a94948635eb5,15086
OLP-0272,2edca3379f026446d5f9fef787833a1fa11b4413ab5b42e995d5eefe31c3d57d,4546
OLP-0273,63113eec71e48783aeaf39d5b1323d74b7c033f40ade9458bd37e6db392d4cf5,12167
'@ | ConvertFrom-Csv

# Exact mismatch sets are frozen after the first calibration run. A mismatch
# outside these IDs is unexplained drift; one inside is still bound by the
# correction assertions and structural digest below.
$expectedMismatch = [ordered]@{
    commands = @('OLP-0257','OLP-0261','OLP-0268','OLP-0271','OLP-0273')
    semantic_tokens = @('OLP-0270')
    math_segments = @('OLP-0255','OLP-0257','OLP-0258','OLP-0260','OLP-0261','OLP-0266','OLP-0267','OLP-0268','OLP-0271','OLP-0272','OLP-0273')
    math_environments = @('OLP-0270','OLP-0271','OLP-0273')
}

$correctionClasses = @(
    'OLP-0255|initial state wording corrected from state one to q_0',
    'OLP-0257|input lies right of the marker; initial configuration includes a trailing blank; finite and infinite run definitions made coherent',
    'OLP-0258|natural-number scope including zero; addition-machine q_0 stroke transition restored as a self-loop',
    'OLP-0260|addition-machine q_0 stroke transition restored as a self-loop',
    'OLP-0261|combined transition cases made disjoint and three inherited q_0 stroke transitions restored as self-loops',
    'OLP-0264|invalid locale marker removed from olchapter optional title',
    'OLP-0267|decode terminology normalized to mendekodekan',
    'OLP-0268|undecidability terminology normalized to ketakterputusan',
    'OLP-0270|left-move frame uses A(x-prime,y); open A(x,y) object correctly classified as formula rather than sentence',
    'OLP-0271|missing T token, machine name, transition variables, run-length scope, rewritten-square exclusions, and left-move coordinates repaired',
    'OLP-0273|finite-domain bound, machine names, left-transition frame, boundary predicate, T-prime theory references, and sentence tokens repaired'
)
$preservedRisks = @(
    'OLP-0273|English source-comment block is retained only as a nonreader comment and excluded from reader-facing residue checks',
    'OLP-0252..OLP-0273|source metadata locators corrected only where their stale Part Chapter or Section value was determinate'
)
$retractions = @(
    'OLP-0266|semantic-token plural suffix is intentionally preserved; element-s is valid OLP token syntax',
    'OLP-0270|sentence-to-formula token change is a mathematical type correction, not token drift'
)

$checks = 0
$actualMismatch = [ordered]@{ commands=@(); semantic_tokens=@(); math_segments=@(); math_environments=@() }
$totals = [ordered]@{
    source_bytes=0L; target_bytes=0L
    source_commands=0L; target_commands=0L
    source_environments=0L; target_environments=0L
    source_semantic_tokens=0L; target_semantic_tokens=0L
    source_ids=0L; target_ids=0L
    source_labels=0L; target_labels=0L
    source_references=0L; target_references=0L
    source_imports=0L; target_imports=0L
    source_math_segments=0L; target_math_segments=0L
    source_math_environments=0L; target_math_environments=0L
}

function Normalize-Newlines([string]$Text) { return ($Text -replace "`r`n", "`n" -replace "`r", "`n") }
function Get-Sha256([string]$Path) { return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant() }
function Get-BytesDigest([byte[]]$Bytes) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash($Bytes))).Replace('-','').ToLowerInvariant() }
    finally { $sha.Dispose() }
}
function Get-TextDigest([object[]]$Items) { return Get-BytesDigest ([Text.Encoding]::UTF8.GetBytes((@($Items) -join "`n"))) }
function Assert-Exact([bool]$Condition,[string]$Name,[string]$Detail='') {
    if (-not $Condition) { throw "FAIL $Name $Detail" }
    $script:checks++
}
function Test-Sequence([object[]]$Expected,[object[]]$Actual) {
    if ($Expected.Count -ne $Actual.Count) { return $false }
    for ($i=0; $i -lt $Expected.Count; $i++) {
        if ([string]$Expected[$i] -cne [string]$Actual[$i]) { return $false }
    }
    return $true
}
function Assert-Sequence([string]$Name,[object[]]$Expected,[object[]]$Actual) {
    Assert-Exact (Test-Sequence $Expected $Actual) $Name "source=$($Expected.Count) target=$($Actual.Count)"
}
function Get-BraceBalance([string]$Text) {
    $balance=0; $comment=$false
    for ($i=0; $i -lt $Text.Length; $i++) {
        $c=$Text[$i]
        if ($comment) { if ($c -eq "`n") { $comment=$false }; continue }
        $slashes=0; for ($j=$i-1; $j -ge 0 -and $Text[$j] -eq '\'; $j--) { $slashes++ }
        $escaped=(($slashes % 2) -eq 1)
        if ($c -eq '%' -and -not $escaped) { $comment=$true; continue }
        if ($escaped) { continue }
        if ($c -eq '{') { $balance++ } elseif ($c -eq '}') { $balance-- }
        if ($balance -lt 0) { return $balance }
    }
    return $balance
}
function Remove-TexComments([string]$Text) {
    $builder=[Text.StringBuilder]::new()
    foreach ($line in ((Normalize-Newlines $Text) -split "`n",0,'SimpleMatch')) {
        $cut=-1
        for ($i=0; $i -lt $line.Length; $i++) {
            if ($line[$i] -ne '%') { continue }
            $slashes=0; for ($j=$i-1; $j -ge 0 -and $line[$j] -eq '\'; $j--) { $slashes++ }
            if (($slashes % 2) -eq 0) { $cut=$i; break }
        }
        if ($cut -ge 0) { [void]$builder.Append($line.Substring(0,$cut)) } else { [void]$builder.Append($line) }
        [void]$builder.Append("`n")
    }
    return $builder.ToString()
}
function Get-Sequence([string]$Text,[string]$Pattern,[string]$Group='value') {
    return @([regex]::Matches($Text,$Pattern,'Singleline') | ForEach-Object { $_.Groups[$Group].Value })
}
function Replace-ProseArgument([string]$Text,[string]$Command) {
    $needle="\$Command{"; $builder=[Text.StringBuilder]::new(); $i=0
    while ($i -lt $Text.Length) {
        if (($i+$needle.Length -le $Text.Length) -and ($Text.Substring($i,$needle.Length) -ceq $needle)) {
            [void]$builder.Append("\$Command{<TEXT>}"); $i += $needle.Length; $depth=1
            while ($i -lt $Text.Length -and $depth -gt 0) {
                if ($Text[$i] -eq '\' -and $i+1 -lt $Text.Length) { $i += 2; continue }
                if ($Text[$i] -eq '{') { $depth++ } elseif ($Text[$i] -eq '}') { $depth-- }
                $i++
            }
            if ($depth -ne 0) { throw "Unbalanced \$Command argument" }
            continue
        }
        [void]$builder.Append($Text[$i]); $i++
    }
    return $builder.ToString()
}
function Mask-ProseArguments([string]$Text) {
    $result=$Text
    foreach ($command in @('text','textrm','intertext','emph')) { $result=Replace-ProseArgument $result $command }
    return $result
}
function Normalize-Math([string]$Text) { return [regex]::Replace($Text,'[\s~]+','') }
function Get-MathSegments([string]$Text) {
    $Text=Mask-ProseArguments $Text
    $items=[Collections.Generic.List[object]]::new()
    foreach ($match in [regex]::Matches($Text,'(?<!\\)\$(.*?)(?<!\\)\$','Singleline')) {
        $items.Add([pscustomobject]@{Index=$match.Index;Value=('INLINE:'+(Normalize-Math $match.Groups[1].Value))})
    }
    foreach ($match in [regex]::Matches($Text,'\\\[(.*?)\\\]','Singleline')) {
        $items.Add([pscustomobject]@{Index=$match.Index;Value=('DISPLAY:'+(Normalize-Math $match.Groups[1].Value))})
    }
    return @($items | Sort-Object Index | ForEach-Object { $_.Value })
}
function Get-MathEnvironments([string]$Text) {
    $Text=Mask-ProseArguments $Text
    $items=[Collections.Generic.List[object]]::new()
    foreach ($environment in @('align','align*','multline','multline*','equation','equation*','aligned','cases','gather','gather*')) {
        $escaped=[regex]::Escape($environment)
        foreach ($match in [regex]::Matches($Text,"\\begin\{$escaped\}(?:\[[^\]]*\])?(?<body>.*?)\\end\{$escaped\}",'Singleline')) {
            $items.Add([pscustomobject]@{Index=$match.Index;Value=($environment+':'+(Normalize-Math $match.Groups['body'].Value))})
        }
    }
    return @($items | Sort-Object Index | ForEach-Object { $_.Value })
}
function Get-IdentifierSequence([string]$Text) {
    $items=[Collections.Generic.List[object]]::new()
    foreach ($m in [regex]::Matches($Text,'\\olfileid(?:\[id\])?\{(?<a>[^{}]+)\}\{(?<b>[^{}]+)\}\{(?<c>[^{}]+)\}')) { $items.Add([pscustomobject]@{Index=$m.Index;Value="file:$($m.Groups['a'].Value):$($m.Groups['b'].Value):$($m.Groups['c'].Value)"}) }
    foreach ($m in [regex]::Matches($Text,'\\olchapter(?:\[[^\]]+\])?\{(?<a>[^{}]+)\}\{(?<b>[^{}]+)\}\{')) { $items.Add([pscustomobject]@{Index=$m.Index;Value="chapter:$($m.Groups['a'].Value):$($m.Groups['b'].Value)"}) }
    foreach ($m in [regex]::Matches($Text,'\\olpart(?:\[[^\]]+\])?\{(?<a>[^{}]+)\}\{')) { $items.Add([pscustomobject]@{Index=$m.Index;Value="part:$($m.Groups['a'].Value)"}) }
    return @($items | Sort-Object Index | ForEach-Object { $_.Value })
}
function Add-StructuralRecord([Collections.Generic.List[string]]$Records,[string]$Id,[string]$Category,[object[]]$Source,[object[]]$Target) {
    $Records.Add("$Id|$Category|$($Source.Count)|$(Get-TextDigest $Source)|$($Target.Count)|$(Get-TextDigest $Target)")
}
function Register-ScopedMismatch([string]$Category,[string]$Id,[object[]]$Source,[object[]]$Target) {
    if (-not (Test-Sequence $Source $Target)) { $script:actualMismatch[$Category] += $Id }
}

Assert-Exact (Test-Path -LiteralPath $manifestPath) 'manifest/present'
Assert-Exact (Test-Path -LiteralPath $configPath) 'config/present'
Assert-Exact ((Get-Sha256 $configPath) -ceq $expectedConfigHash) 'config/hash'
Assert-Exact ($targetBindings.Count -eq 22) 'bindings/count'

$manifest=Import-Csv -LiteralPath $manifestPath
$batch=@($manifest | Where-Object { [int]$_.stable_order -ge 252 -and [int]$_.stable_order -le 273 } | Sort-Object {[int]$_.stable_order})
$expectedIds=@(252..273 | ForEach-Object { 'OLP-{0:D4}' -f $_ })
Assert-Exact ($batch.Count -eq 22) 'manifest/batch-count'
Assert-Sequence 'manifest/ordered-ids' $expectedIds @($batch.closure_id)
Assert-Sequence 'bindings/ordered-ids' $expectedIds @($targetBindings.Id)

$manifestRecords=@($batch | ForEach-Object { "$($_.closure_id)|$($_.stable_order)|$($_.source_commit)|$($_.source_path)|$($_.source_sha256.ToLowerInvariant())|$($_.target_path)" })
$manifestBindingDigest=Get-TextDigest $manifestRecords
$literalPatterns=[ordered]@{
    environments='(?<value>\\(?:begin|end)\{[^{}]+\})'
    labels='(?<value>\\ollabel\{[^{}]+\})'
    references='(?<value>\\(?:olref|Olref)(?:\[[^\]]*\]){0,3}\{[^{}]+\}|\\(?:cref|Cref)\{[^{}]+\})'
    imports='(?<value>\\olimport\*?(?:\[[^\]]*\])?\{[^{}]+\})'
}
$structuralRecords=[Collections.Generic.List[string]]::new()
$bindingRecords=[Collections.Generic.List[string]]::new()
$allTargets=[Text.StringBuilder]::new()
$tokenBases=[Collections.Generic.List[string]]::new()

for ($i=0; $i -lt $batch.Count; $i++) {
    $row=$batch[$i]; $binding=$targetBindings[$i]; $id=$row.closure_id
    Assert-Exact ($row.source_commit -ceq $expectedCommit) "$id/commit"
    Assert-Exact ($row.target_path -ceq "locale/id/$($row.source_path)") "$id/target-path"
    $sourcePath=Join-Path $repoRoot ($row.source_path -replace '/','\')
    $targetPath=Join-Path $repoRoot ($row.target_path -replace '/','\')
    Assert-Exact (Test-Path -LiteralPath $sourcePath) "$id/source-present"
    Assert-Exact (Test-Path -LiteralPath $targetPath) "$id/target-present"
    Assert-Exact ((Get-Sha256 $sourcePath) -ceq $row.source_sha256.ToLowerInvariant()) "$id/source-hash"
    Assert-Exact ((Get-Sha256 $targetPath) -ceq $binding.TargetHash) "$id/target-hash"
    Assert-Exact ((Get-Item -LiteralPath $targetPath).Length -eq [int64]$binding.TargetBytes) "$id/target-bytes"
    $sourceRaw=Normalize-Newlines ([IO.File]::ReadAllText($sourcePath))
    $targetRaw=Normalize-Newlines ([IO.File]::ReadAllText($targetPath))
    [void]$allTargets.AppendLine($targetRaw)
    $totals.source_bytes += (Get-Item -LiteralPath $sourcePath).Length
    $totals.target_bytes += (Get-Item -LiteralPath $targetPath).Length
    Assert-Exact ((Get-BraceBalance $sourceRaw) -eq 0) "$id/source-braces"
    Assert-Exact ((Get-BraceBalance $targetRaw) -eq 0) "$id/target-braces"
    Assert-Exact (-not [regex]::IsMatch($targetRaw,'[\x00-\x08\x0B\x0C\x0E-\x1F]')) "$id/no-control-bytes"

    $source=Remove-TexComments $sourceRaw; $target=Remove-TexComments $targetRaw
    $sourceCommands=@(Get-Sequence $source '(?<value>\\[A-Za-z@]+|\\.)')
    $targetCommands=@(Get-Sequence $target '(?<value>\\[A-Za-z@]+|\\.)')
    Register-ScopedMismatch 'commands' $id $sourceCommands $targetCommands
    $totals.source_commands += $sourceCommands.Count; $totals.target_commands += $targetCommands.Count
    Add-StructuralRecord $structuralRecords $id 'commands' $sourceCommands $targetCommands

    foreach ($category in $literalPatterns.Keys) {
        $sourceSequence=@(Get-Sequence $source $literalPatterns[$category])
        $targetSequence=@(Get-Sequence $target $literalPatterns[$category])
        Assert-Sequence "$id/$category" $sourceSequence $targetSequence
        $totals["source_$category"] += $sourceSequence.Count
        $totals["target_$category"] += $targetSequence.Count
        Add-StructuralRecord $structuralRecords $id $category $sourceSequence $targetSequence
    }

    $sourceTokens=@(Get-Sequence $source '!!(?:\^)?(?:a|A)?\{(?<value>[^{}]+)\}(?:s|d)?' | ForEach-Object {[regex]::Replace($_,'\s+',' ')})
    $targetTokens=@(Get-Sequence $target '!!(?:\^)?(?:a|A)?\{(?<value>[^{}]+)\}(?:s|d)?' | ForEach-Object {[regex]::Replace($_,'\s+',' ')})
    Register-ScopedMismatch 'semantic_tokens' $id $sourceTokens $targetTokens
    foreach ($token in $targetTokens) { $tokenBases.Add($token) }
    $totals.source_semantic_tokens += $sourceTokens.Count; $totals.target_semantic_tokens += $targetTokens.Count
    Add-StructuralRecord $structuralRecords $id 'semantic_tokens' $sourceTokens $targetTokens

    $sourceIds=@(Get-IdentifierSequence $source); $targetIds=@(Get-IdentifierSequence $target)
    Assert-Sequence "$id/ids" $sourceIds $targetIds
    $totals.source_ids += $sourceIds.Count; $totals.target_ids += $targetIds.Count
    Add-StructuralRecord $structuralRecords $id 'ids' $sourceIds $targetIds

    $sourceMath=@(Get-MathSegments $source); $targetMath=@(Get-MathSegments $target)
    Register-ScopedMismatch 'math_segments' $id $sourceMath $targetMath
    $totals.source_math_segments += $sourceMath.Count; $totals.target_math_segments += $targetMath.Count
    Add-StructuralRecord $structuralRecords $id 'math_segments' $sourceMath $targetMath

    $sourceMathEnv=@(Get-MathEnvironments $source); $targetMathEnv=@(Get-MathEnvironments $target)
    Register-ScopedMismatch 'math_environments' $id $sourceMathEnv $targetMathEnv
    $totals.source_math_environments += $sourceMathEnv.Count; $totals.target_math_environments += $targetMathEnv.Count
    Add-StructuralRecord $structuralRecords $id 'math_environments' $sourceMathEnv $targetMathEnv
    $bindingRecords.Add("$id|$($binding.TargetHash)|$($binding.TargetBytes)")
}

$allTargetText=$allTargets.ToString()
Assert-Exact (-not [regex]::IsMatch([regex]::Replace((Remove-TexComments $allTargetText),'!!(?:\^)?(?:a|A)?\{[^{}\r\n]+\}(?:s|d)?',''),'!!')) 'batch/semantic-token-forms'
Assert-Exact (-not [regex]::IsMatch((Remove-TexComments $allTargetText),'\\(?:olchapter|olpart)\[id\]')) 'batch/no-id-as-short-title'
Assert-Exact (-not [regex]::IsMatch($allTargetText,'\b(?:TODO|FIXME|XXX)\b')) 'batch/no-placeholders'

# Every reader-facing semantic token used by this tranche must have an
# Indonesian locale override; an upstream English fallback is not admitted.
$configText=[IO.File]::ReadAllText($configPath)
foreach ($token in @($tokenBases | Sort-Object -Unique)) {
    Assert-Exact ([regex]::IsMatch($configText,'\\settexttoken(?:\[[^\]]*\])?\{'+[regex]::Escape($token)+'\}')) "token/localized/$token"
}

# High-confidence source-correction assertions. Each checks both the admitted
# form and rejection of the exact defective form or scope.
$p255=[IO.File]::ReadAllText((Join-Path $repoRoot 'locale\id\content\turing-machines\machines-computations\representing-tms.tex'))
Assert-Exact ($p255.Contains('keadaan~$q_0$')) 'OLP-0255/q0-wording'
$p257=[IO.File]::ReadAllText((Join-Path $repoRoot 'locale\id\content\turing-machines\machines-computations\configuration.tex'))
Assert-Exact ($p257.Contains('di sebelah kanan penanda ujung kiri')) 'OLP-0257/right-of-marker'
Assert-Exact ([regex]::IsMatch($p257,'barisan berhingga atau tak\s+berhingga')) 'OLP-0257/run-finite-or-infinite'
$p261=[IO.File]::ReadAllText((Join-Path $repoRoot 'locale\id\content\turing-machines\machines-computations\combining-machines.tex'))
Assert-Exact ($p261.Contains('$q \in Q$ dan $\delta(q,\sigma)$ terdefinisi')) 'OLP-0261/disjoint-cases'
$p270=[IO.File]::ReadAllText((Join-Path $repoRoot 'locale\id\content\turing-machines\undecidability\representing-tms.tex'))
Assert-Exact ($p270.Contains("!A(x', y)")) 'OLP-0270/left-frame-coordinate'
Assert-Exact ($p270.Contains('konjungsi semua !!{formula}')) 'OLP-0270/open-formula-type'
$p271=[IO.File]::ReadAllText((Join-Path $repoRoot 'locale\id\content\turing-machines\undecidability\verification.tex'))
Assert-Exact (([regex]::Matches($p271,'\\bigwedge_\{\\substack\{0\\le i\\le k\\\\i\\ne m\}\}')).Count -eq 2) 'OLP-0271/rewritten-square-exclusion'
$p273=[IO.File]::ReadAllText((Join-Path $repoRoot 'locale\id\content\turing-machines\undecidability\trakhtenbrot.tex'))
Assert-Exact ($p273.Contains('\max(k+1,\len{w})')) 'OLP-0273/finite-bound'
Assert-Exact ($p273.Contains("!B(y')")) 'OLP-0273/left-boundary'

$calibrating=($expectedManifestBindingDigest -ceq '__CALIBRATE__')
foreach ($category in $expectedMismatch.Keys) {
    if ($calibrating) { "CALIBRATE mismatch_$category=$($actualMismatch[$category] -join ',')" }
    else { Assert-Sequence "scoped-mismatch/$category" @($expectedMismatch[$category]) @($actualMismatch[$category]) }
}

$reviewRecords=@($correctionClasses + $preservedRisks + $retractions)
$manifestDigest=Get-TextDigest $manifestRecords
$targetDigest=Get-TextDigest @($bindingRecords)
$structuralDigest=Get-TextDigest @($structuralRecords)
$reviewDigest=Get-TextDigest $reviewRecords
if ($calibrating) {
    "CALIBRATE manifest=$manifestDigest"
    "CALIBRATE target=$targetDigest"
    "CALIBRATE structural=$structuralDigest"
    "CALIBRATE review=$reviewDigest"
    foreach ($key in $totals.Keys) { "CALIBRATE total_$key=$($totals[$key])" }
    throw 'CALIBRATION COMPLETE: freeze emitted sets, digests, and totals.'
}
Assert-Exact ($manifestDigest -ceq $expectedManifestBindingDigest) 'batch/manifest-digest'
Assert-Exact ($targetDigest -ceq $expectedTargetBindingDigest) 'batch/target-digest'
Assert-Exact ($structuralDigest -ceq $expectedStructuralDigest) 'batch/structural-digest'
Assert-Exact ($reviewDigest -ceq $expectedReviewDigest) 'batch/review-digest'

$expectedTotals=[ordered]@{
    source_bytes=126811; target_bytes=132412
    source_commands=3037; target_commands=3047
    source_environments=428; target_environments=428
    source_semantic_tokens=97; target_semantic_tokens=97
    source_ids=22; target_ids=22
    source_labels=40; target_labels=40
    source_references=60; target_references=60
    source_imports=21; target_imports=21
    source_math_segments=1365; target_math_segments=1364
    source_math_environments=22; target_math_environments=22
}
foreach ($key in $totals.Keys) { Assert-Exact ($totals[$key] -eq $expectedTotals[$key]) "batch/total-$key" "expected=$($expectedTotals[$key]) actual=$($totals[$key])" }

"TARGET_BINDING_DIGEST sha256=$targetDigest files=$($batch.Count) bytes=$($totals.target_bytes)"
"SOURCE_BINDING_DIGEST sha256=$manifestDigest files=$($batch.Count) bytes=$($totals.source_bytes) commit=$expectedCommit"
"STRUCTURAL_TOTALS commands=$($totals.source_commands)/$($totals.target_commands) environments=$($totals.source_environments)/$($totals.target_environments) tokens=$($totals.source_semantic_tokens)/$($totals.target_semantic_tokens) ids=$($totals.source_ids)/$($totals.target_ids) labels=$($totals.source_labels)/$($totals.target_labels) refs=$($totals.source_references)/$($totals.target_references) imports=$($totals.source_imports)/$($totals.target_imports) math=$($totals.source_math_segments)/$($totals.target_math_segments) math_env=$($totals.source_math_environments)/$($totals.target_math_environments)"
"REVIEW_TOTALS correction_classes=$($correctionClasses.Count) retractions=$($retractions.Count) preserved_risks=$($preservedRisks.Count) review_sha256=$reviewDigest"
"TURING_MACHINES_BATCH_REPLAY_OK files=$($batch.Count) checks=$checks closure=OLP-0252..OLP-0273"
