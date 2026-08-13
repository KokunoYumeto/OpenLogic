$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$localeRoot = $PSScriptRoot
$repoRoot = [IO.Path]::GetFullPath((Join-Path $localeRoot '..\..'))
$controlRoot = [IO.Path]::GetFullPath((Join-Path $repoRoot '..\_control'))
$manifestPath = Join-Path $controlRoot 'OPENLOGIC_CLOSURE_MANIFEST_20260812.csv'
$configPath = Join-Path $localeRoot 'open-logic-config.sty'
$expectedCommit = '9620cc73f9c8e0ad003c514a5d3748f29611c4c0'
$expectedConfigHash = '3e3215e07c82e69014b34e78ede16777d6ea53450619088b9ffa92b892f5add0'

# Immutable closure/source-object/target-byte binding for OLP-0182..0190.
$units = @(
    [pscustomobject]@{ Id='OLP-0182'; Path='content/model-theory/model-theory.tex'; SourceBlob='b548caaa52fd7ba85a7fe49d8eb9b0282a7c40d8'; SourceHash='d344ffda1bed36ff693a10b8093066703e9f00ce0ca64babaea50d5a2d25613f'; TargetHash='865ef7a75844bed0076d63005c04a66038c8fb3b125da56b36c70f0232a86aac' }
    [pscustomobject]@{ Id='OLP-0183'; Path='content/model-theory/basics/basics.tex'; SourceBlob='f06b1fe36a29d6fb561bf10cee426e084ed5c87d'; SourceHash='dbaab317a40a064d1325f5f071b3be75c7a3fa581423f7a2551cf9f4b06873b4'; TargetHash='44d4eedda8bc6c90f68f9a72845ac841a525d177d9c454857ab4d28ec3c9adf4' }
    [pscustomobject]@{ Id='OLP-0184'; Path='content/model-theory/basics/reducts-and-expansions.tex'; SourceBlob='65f26ce3014d1df9df9f28c315934972e4bff488'; SourceHash='f570b7501195fe1f9f137521c31af6e33c31c6d87d304e82649408b523aec20d'; TargetHash='2ec4dee5ed0193a016974974a0b863051c504a7ea0b7860982dbf76a2feecacf' }
    [pscustomobject]@{ Id='OLP-0185'; Path='content/model-theory/basics/substructures.tex'; SourceBlob='55f6a8d725ae2393272a7f7792b86031b9a44f80'; SourceHash='2c47b8add212cb4b0f9029d4d68acb4e56e8827a7da2e44ea2c5914b2f6f27d1'; TargetHash='649402a762e9efc1c22e3639b95bf715192694fc25c17329e81cbf3d6851e3c7' }
    [pscustomobject]@{ Id='OLP-0186'; Path='content/model-theory/basics/overspill.tex'; SourceBlob='6312ce4e5d06308a07ccfbc3d5c4b73557b5e20e'; SourceHash='c0bcbf30f27166ac4d28caa048c645701e64a64407184b553c37666ecdf7fbc5'; TargetHash='a30f1fbcf757cc2b88215c36ebf5fd0df0a8c2bf55b63abacc929be635f55db7' }
    [pscustomobject]@{ Id='OLP-0187'; Path='content/model-theory/basics/isomorphism.tex'; SourceBlob='f90d2e2c068cfbb8eedcadf0c05519d1b92c3217'; SourceHash='400ced4b63fe2ab03f95db16b1169e3bfa382ae0b4346c839c36220f51aac563'; TargetHash='d6796fd03e7dec30c975a5be47b0c921eb739e20a34a05a4ed4b5c7629b3b67a' }
    [pscustomobject]@{ Id='OLP-0188'; Path='content/model-theory/basics/theory-of-m.tex'; SourceBlob='b7f6ff8517a593d1518a4301b760a3a95c6f36a0'; SourceHash='29fadddc04faea7888457a0eb536fbbef4d9942e4076a14f9ed186b61813e7a7'; TargetHash='b4e9d7b74b35bd46253f1d3361fa7004aa17af4c221f8d4162d4d2de8a32ecb3' }
    [pscustomobject]@{ Id='OLP-0189'; Path='content/model-theory/basics/partial-iso.tex'; SourceBlob='7fcf4821493afa7792b7aac64e53c3091efbd82f'; SourceHash='9233c0428a52f321404fd272342e7e2ad90b16efcc7c6a0c5d766717eb739e97'; TargetHash='99b60edc8873fc776f48cba2eabab075722fc24abb6bf7c2c3d3bc1726e7e9ad' }
    [pscustomobject]@{ Id='OLP-0190'; Path='content/model-theory/basics/dlo.tex'; SourceBlob='8d26dced0369a8993c5bab1dfbc4ac15d144f8c7'; SourceHash='2176d8add7d120c359c3a1f83010e0dcbcfa8a70c3d7595bf87931eb67354a8a'; TargetHash='2b51e8ca5f2cc7be5d411b76b921bff42252366088b3f0c66bcdf3f45fdcba00' }
)

$checks = 0
$normalizationMatches = 0
$sourceCorrectionClasses = 0
$targetReviewClasses = 0
$terminologyClasses = 0
$riskClasses = 0
$retractionClasses = 0
$totals = [ordered]@{ commands=0; environments=0; semantic_tokens=0; labels=0; references=0; citations=0; assets=0; imports=0; tagged_items=0; tag_conditionals=0; math_skeletons=0; math_environments=0; localized_file_ids=0; chapter_ids=0; part_ids=0 }

function Normalize-Newlines([string]$Text) { return ($Text -replace "`r`n", "`n" -replace "`r", "`n") }
function Get-Sha256([string]$Path) { return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant() }
function Get-BytesSha256([byte[]]$Bytes) { $sha=[Security.Cryptography.SHA256]::Create(); try { return ([BitConverter]::ToString($sha.ComputeHash($Bytes))).Replace('-','').ToLowerInvariant() } finally { $sha.Dispose() } }
function Get-TextDigest([string[]]$Items) { return Get-BytesSha256 ([Text.Encoding]::UTF8.GetBytes(($Items -join "`n"))) }
function Assert-Exact([bool]$Condition,[string]$Name,[string]$Detail='') { if (-not $Condition) { throw "FAIL $Name $Detail" }; $script:checks++; if ($Detail) { "PASS $Name $Detail" } else { "PASS $Name" } }
function Assert-Sequence([string]$Name,[object[]]$Expected,[object[]]$Actual) { if ($Expected.Count -ne $Actual.Count) { throw "$Name count mismatch source=$($Expected.Count) target=$($Actual.Count)" }; for ($i=0; $i -lt $Expected.Count; $i++) { if ([string]$Expected[$i] -cne [string]$Actual[$i]) { throw "$Name mismatch index=$i`nSOURCE=$($Expected[$i])`nTARGET=$($Actual[$i])" } }; $script:checks++; "PASS $Name count=$($Actual.Count)" }
function Assert-RegexCount([string]$Name,[string]$Text,[string]$Pattern,[int]$Expected) { $n=([regex]::Matches($Text,$Pattern,'Singleline')).Count; Assert-Exact ($n -eq $Expected) $Name "count=$n" }

function Invoke-GitBytes([string]$WorkingDirectory,[string[]]$Arguments) {
    $start=[Diagnostics.ProcessStartInfo]::new(); $start.FileName='git'; $start.WorkingDirectory=$WorkingDirectory; $start.UseShellExecute=$false; $start.RedirectStandardOutput=$true; $start.RedirectStandardError=$true
    foreach ($argument in $Arguments) { [void]$start.ArgumentList.Add($argument) }
    $process=[Diagnostics.Process]::Start($start); $memory=[IO.MemoryStream]::new()
    try { $copy=$process.StandardOutput.BaseStream.CopyToAsync($memory); $errorTask=$process.StandardError.ReadToEndAsync(); [void]$copy.GetAwaiter().GetResult(); $errorText=$errorTask.GetAwaiter().GetResult(); $process.WaitForExit(); if ($process.ExitCode -ne 0) { throw "git failed: $errorText" }; return ,$memory.ToArray() } finally { $memory.Dispose(); $process.Dispose() }
}

function Get-BraceBalance([string]$Text) {
    $balance=0; $comment=$false
    for ($i=0; $i -lt $Text.Length; $i++) { $c=$Text[$i]; if ($comment) { if ($c -eq "`n") { $comment=$false }; continue }; $slashes=0; for ($j=$i-1; $j -ge 0 -and $Text[$j] -eq '\'; $j--) { $slashes++ }; $escaped=(($slashes % 2) -eq 1); if ($c -eq '%' -and -not $escaped) { $comment=$true; continue }; if ($escaped) { continue }; if ($c -eq '{') { $balance++ } elseif ($c -eq '}') { $balance-- }; if ($balance -lt 0) { return $balance } }
    return $balance
}
function Remove-TexComments([string]$Text) {
    $builder=[Text.StringBuilder]::new()
    foreach ($line in ((Normalize-Newlines $Text) -split "`n",0,'SimpleMatch')) { $cut=-1; for ($i=0; $i -lt $line.Length; $i++) { if ($line[$i] -ne '%') { continue }; $slashes=0; for ($j=$i-1; $j -ge 0 -and $line[$j] -eq '\'; $j--) { $slashes++ }; if (($slashes % 2) -eq 0) { $cut=$i; break } }; if ($cut -ge 0) { [void]$builder.Append($line.Substring(0,$cut)) } else { [void]$builder.Append($line) }; [void]$builder.Append("`n") }
    return $builder.ToString()
}
function Get-Sequence([string]$Text,[string]$Pattern,[string]$Group='value') { return @([regex]::Matches($Text,$Pattern,'Singleline') | ForEach-Object { $_.Groups[$Group].Value }) }
function Replace-LiteralExact([string]$Text,[string]$Old,[string]$New,[int]$Expected,[string]$Name) { $n=([regex]::Matches($Text,[regex]::Escape($Old))).Count; if ($n -ne $Expected) { throw "$Name normalization expected=$Expected actual=$n" }; $script:normalizationMatches += $n; return $Text.Replace($Old,$New) }

function Get-CorrectedSource([string]$Path,[string]$Text) {
    $result=Normalize-Newlines $Text
    if ($Path -ceq 'content/model-theory/basics/isomorphism.tex') {
        $result=Replace-LiteralExact $result '\Value{t}{M''}[h \circ s] & = \Assign{f}{M}(' '\Value{t}{M''}[h \circ s] & = \Assign{f}{M''}(' 1 'isomorphism/term-induction-codomain-interpretation'
        $result=Replace-LiteralExact $result 'h(\Assign{f}{M}(\Value{t_1}{M}[s], \dots, \Value{t_n}{M}[s]) \notag' 'h(\Assign{f}{M}(\Value{t_1}{M}[s], \dots, \Value{t_n}{M}[s])) \notag' 1 'isomorphism/missing-closing-parenthesis'
    }
    if ($Path -ceq 'content/model-theory/basics/partial-iso.tex') {
        $result=Replace-LiteralExact $result 'n+1 =2r' 'n+1 =2r+2' 1 'partial-iso/back-enumeration-index'
        $result=Replace-LiteralExact $result 'by recursion on $n$ as follows:' 'by recursion on $n$ as follows: Let the two sequences have length~$k$.' 1 'partial-iso/sequence-length-binder'
        $result=Replace-LiteralExact $result 'x_1$, \dots,~$x_n$' 'x_1$, \dots,~$x_k$' 1 'partial-iso/sequence-length-variable'
    }
    if ($Path -ceq 'content/model-theory/basics/dlo.tex') {
        $result=Replace-LiteralExact $result '!!a{enumerable} !!{structure}~$\Struct{S}$ such that' '!!a{structure}~$\Struct{S}$ that is !!{enumerable} such that' 1 'dlo/token-order-existential-structure'
        $result=Replace-LiteralExact $result "is !!a{enumerable} dense`n  linear ordering without endpoints" "is a dense`n  linear ordering without endpoints that is !!{enumerable}" 1 'dlo/token-order-predicative-enumerable'
    }
    return $result
}

function Replace-ProseArgument([string]$Text,[string]$Command) {
    $needle="\$Command{"; $builder=[Text.StringBuilder]::new(); $i=0
    while ($i -lt $Text.Length) { if (($i+$needle.Length -le $Text.Length) -and ($Text.Substring($i,$needle.Length) -ceq $needle)) { [void]$builder.Append("\$Command{<TEXT>}"); $i += $needle.Length; $depth=1; while ($i -lt $Text.Length -and $depth -gt 0) { if ($Text[$i] -eq '\' -and $i+1 -lt $Text.Length) { $i += 2; continue }; if ($Text[$i] -eq '{') { $depth++ } elseif ($Text[$i] -eq '}') { $depth-- }; $i++ }; if ($depth -ne 0) { throw "Unbalanced \$Command" }; continue }; [void]$builder.Append($Text[$i]); $i++ }
    return $builder.ToString()
}
function Normalize-Math([string]$Text) { $result=$Text; foreach ($command in @('text','textrm','intertext','emph')) { $result=Replace-ProseArgument $result $command }; return [regex]::Replace($result,'[\s~]+','') }
function Get-MathSkeletons([string]$Text) { $items=[Collections.Generic.List[object]]::new(); foreach ($match in [regex]::Matches($Text,'(?<!\\)\$(.*?)(?<!\\)\$','Singleline')) { $items.Add([pscustomobject]@{Index=$match.Index;Value=('INLINE:'+(Normalize-Math $match.Value))}) }; foreach ($match in [regex]::Matches($Text,'\\\[(.*?)\\\]','Singleline')) { $items.Add([pscustomobject]@{Index=$match.Index;Value=('DISPLAY:'+(Normalize-Math $match.Value))}) }; return @($items | Sort-Object Index | ForEach-Object { $_.Value }) }
function Get-MathEnvironmentStructures([string]$Text) { $items=[Collections.Generic.List[object]]::new(); foreach ($environment in @('align','align*','multline','multline*','equation','equation*','aligned','cases')) { $escaped=[regex]::Escape($environment); foreach ($match in [regex]::Matches($Text,"\\begin\{$escaped\}(?:\[[^\]]*\])?(?<body>.*?)\\end\{$escaped\}",'Singleline')) { $body=$match.Groups['body'].Value; foreach ($command in @('text','textrm','intertext')) { $body=Replace-ProseArgument $body $command }; $items.Add([pscustomobject]@{Index=$match.Index;Value=($environment+':'+(Normalize-Math $body))}) } }; return @($items | Sort-Object Index | ForEach-Object { $_.Value }) }
function Get-CommandSequence([string]$Text) { return @(Get-Sequence $Text '(?<value>\\[A-Za-z@]+|\\.)') }
function Get-SemanticTokenSequence([string]$Text) { return @([regex]::Matches($Text,'!!(?:\^)?(?:a|A)?\{(?<value>[^{}]+)\}(?:s|d)?','Singleline') | ForEach-Object { [regex]::Replace($_.Groups['value'].Value,'\s+',' ') }) }
function Remove-NonReaderSurface([string]$Text) { $result=Remove-TexComments $Text; $result=[regex]::Replace($result,'\\\[.*?\\\]','','Singleline'); $result=[regex]::Replace($result,'(?<!\\)\$.*?(?<!\\)\$','','Singleline'); $result=[regex]::Replace($result,'!!(?:\^)?(?:a|A)?\{[^{}]+\}(?:s|d)?',''); return $result }
function Assert-TargetReview([string]$Name,[string]$Text,[string]$Accepted,[int]$AcceptedCount,[string[]]$Rejected) { Assert-RegexCount "target-review/$Name/accepted" $Text $Accepted $AcceptedCount; foreach ($pattern in $Rejected) { Assert-RegexCount "target-review/$Name/rejected" $Text $pattern 0 }; $script:targetReviewClasses++ }
function Assert-SourceCorrection([string]$Name,[string]$Source,[string]$SourcePattern,[int]$SourceCount,[string]$Target,[string]$TargetPattern,[int]$TargetCount) { Assert-RegexCount "source-correction/$Name/source" $Source $SourcePattern $SourceCount; Assert-RegexCount "source-correction/$Name/target" $Target $TargetPattern $TargetCount; $script:sourceCorrectionClasses++ }

$commitType=@(& git -C $repoRoot cat-file -t $expectedCommit 2>$null)
Assert-Exact (($LASTEXITCODE -eq 0) -and $commitType.Count -eq 1 -and $commitType[0] -ceq 'commit') 'frozen-source-commit-object' $expectedCommit
Assert-Exact (Test-Path -LiteralPath $manifestPath) 'closure-manifest-present' $manifestPath
Assert-Exact (Test-Path -LiteralPath $configPath) 'locale-config-present' $configPath
Assert-Exact ((Get-Sha256 $configPath) -ceq $expectedConfigHash) 'locale-config-hash' $expectedConfigHash
$config=Normalize-Newlines ([IO.File]::ReadAllText($configPath))
$requiredTokens=[ordered]@{ structure='struktur'; sentence='kalimat'; language='bahasa'; constant='simbol konstanta'; predicate='simbol predikat'; function='simbol fungsi'; domain='domain'; injective='injektif'; surjective='surjektif'; enumerable='terhitung'; formula='formula'; variable='variabel' }
foreach ($name in $requiredTokens.Keys) { Assert-RegexCount "locale-config/token-$name" $config ("\\settexttoken\{"+[regex]::Escape($name)+"\}[^\r\n]*\{"+[regex]::Escape($requiredTokens[$name])+"\}") 1 }

$manifest=Import-Csv -LiteralPath $manifestPath
$batch=@($manifest | Where-Object { [int]$_.stable_order -ge 182 -and [int]$_.stable_order -le 190 } | Sort-Object { [int]$_.stable_order })
Assert-Exact ($batch.Count -eq $units.Count) 'manifest-batch-count' "count=$($units.Count)"
Assert-Sequence 'manifest/ordered-closure-ids' @($units.Id) @($batch.closure_id)

$literal=[ordered]@{ environments='(?<value>\\(?:begin|end)\{[^{}]+\})'; labels='(?<value>\\ollabel\{[^{}]+\})'; references='(?<value>\\(?:olref|Olref)(?:\[[^\]]*\]){0,3}\{[^{}]+\}|\\(?:cref|Cref)\{[^{}]+\})'; citations='(?<value>\\cite[a-zA-Z]*\{[^{}]+\})'; assets='(?<value>\\olasset(?:\[[^\]]*\])?\{[^{}]+\})'; imports='(?<value>\\olimport\*?(?:\[[^\]]*\])?\{[^{}]+\})'; tagged_items='(?<value>\\tagitem\{[^{}]+\}|\\tagprob\{[^{}]+\}|\\tagendprob\b)'; tag_conditionals='(?<value>\\iftag\{[^{}]+\})' }
$rawSource=@{}; $rawTarget=@{}; $sourceRecords=[Collections.Generic.List[string]]::new(); $targetRecords=[Collections.Generic.List[string]]::new()

for ($i=0; $i -lt $units.Count; $i++) {
    $unit=$units[$i]; $row=$batch[$i]; $sourcePath=Join-Path $repoRoot ($unit.Path -replace '/','\'); $targetRelative="locale/id/$($unit.Path)"; $targetPath=Join-Path $repoRoot ($targetRelative -replace '/','\')
    Assert-Exact ($row.closure_id -ceq $unit.Id -and [int]$row.stable_order -eq (182+$i) -and $row.source_commit -ceq $expectedCommit -and $row.source_path -ceq $unit.Path -and $row.source_sha256.ToLowerInvariant() -ceq $unit.SourceHash -and $row.target_path -ceq $targetRelative -and $row.closure_included -ceq 'true' -and $row.canonical_reader_reachable -ceq 'true') "$($unit.Id)/manifest-binding"
    Assert-Exact (Test-Path -LiteralPath $sourcePath) "$($unit.Id)/source-present"
    Assert-Exact (Test-Path -LiteralPath $targetPath) "$($unit.Id)/target-present"
    Assert-Exact ((Get-Sha256 $sourcePath) -ceq $unit.SourceHash) "$($unit.Id)/source-worktree-hash" $unit.SourceHash
    $blob=@(& git -C $repoRoot rev-parse --verify "$expectedCommit`:$($unit.Path)" 2>$null)
    Assert-Exact ($LASTEXITCODE -eq 0 -and $blob.Count -eq 1 -and $blob[0] -ceq $unit.SourceBlob) "$($unit.Id)/source-git-object" $unit.SourceBlob
    $sourceRaw=Normalize-Newlines ([Text.Encoding]::UTF8.GetString((Invoke-GitBytes $repoRoot @('cat-file','blob',$unit.SourceBlob))))
    $worktreeRaw=Normalize-Newlines ([IO.File]::ReadAllText($sourcePath))
    Assert-Exact ($sourceRaw -ceq $worktreeRaw) "$($unit.Id)/source-content-binding" 'newline-normalized=true'
    Assert-Exact ((Get-Sha256 $targetPath) -ceq $unit.TargetHash) "$($unit.Id)/target-hash" $unit.TargetHash
    $targetRaw=Normalize-Newlines ([IO.File]::ReadAllText($targetPath)); $rawSource[$unit.Path]=$sourceRaw; $rawTarget[$unit.Path]=$targetRaw
    $source=Remove-TexComments (Get-CorrectedSource $unit.Path $sourceRaw); $target=Remove-TexComments $targetRaw
    Assert-Exact ((Get-BraceBalance $sourceRaw) -eq 0) "$($unit.Id)/source-brace-balance"
    Assert-Exact ((Get-BraceBalance $targetRaw) -eq 0) "$($unit.Id)/target-brace-balance"
    $expected=@(Get-CommandSequence $source); $actual=@(Get-CommandSequence $target); Assert-Sequence "$($unit.Id)/commands" $expected $actual; $totals.commands += $actual.Count
    foreach ($name in $literal.Keys) { $expected=@(Get-Sequence $source $literal[$name]); $actual=@(Get-Sequence $target $literal[$name]); Assert-Sequence "$($unit.Id)/$name" $expected $actual; $totals[$name] += $actual.Count }
    $expected=@(Get-SemanticTokenSequence $source); $actual=@(Get-SemanticTokenSequence $target); Assert-Sequence "$($unit.Id)/semantic-token-order" $expected $actual; $totals.semantic_tokens += $actual.Count
    $expected=@(Get-MathSkeletons $source); $actual=@(Get-MathSkeletons $target); Assert-Sequence "$($unit.Id)/math-skeletons" $expected $actual; $totals.math_skeletons += $actual.Count
    $expected=@(Get-MathEnvironmentStructures $source); $actual=@(Get-MathEnvironmentStructures $target); Assert-Sequence "$($unit.Id)/math-environments" $expected $actual; $totals.math_environments += $actual.Count
    $sourceFileIds=@([regex]::Matches($source,'\\olfileid(?:\[[^\]]+\])?')); $targetFileIds=@([regex]::Matches($target,'\\olfileid\[id\]')); Assert-Exact ($sourceFileIds.Count -eq $targetFileIds.Count) "$($unit.Id)/localized-file-ids" "count=$($targetFileIds.Count)"; $totals.localized_file_ids += $targetFileIds.Count
    $sourceChapterIds=@([regex]::Matches($source,'\\olchapter(?:\[[^\]]+\])?')); $targetChapterIds=@([regex]::Matches($target,'\\olchapter(?!\[)')); Assert-Exact ($sourceChapterIds.Count -eq $targetChapterIds.Count) "$($unit.Id)/chapter-ids" "count=$($targetChapterIds.Count)"; $totals.chapter_ids += $targetChapterIds.Count
    $sourcePartIds=@([regex]::Matches($source,'\\olpart(?:\[[^\]]+\])?')); $targetPartIds=@([regex]::Matches($target,'\\olpart(?!\[)')); Assert-Exact ($sourcePartIds.Count -eq $targetPartIds.Count) "$($unit.Id)/part-ids" "count=$($targetPartIds.Count)"; $totals.part_ids += $targetPartIds.Count
    $sourceRecords.Add("$($unit.Id)|$($unit.SourceBlob)|$($unit.SourceHash)|$($unit.Path)"); $targetRecords.Add("$($unit.Id)|$($unit.TargetHash)|$targetRelative")
}

$reduct='content/model-theory/basics/reducts-and-expansions.tex'; $sub='content/model-theory/basics/substructures.tex'; $iso='content/model-theory/basics/isomorphism.tex'; $theory='content/model-theory/basics/theory-of-m.tex'; $partial='content/model-theory/basics/partial-iso.tex'; $dlo='content/model-theory/basics/dlo.tex'

# Nine exact upstream mathematical/editorial defects corrected in the target.
Assert-SourceCorrection 'substructure/nonempty-carrier' $rawSource[$sub] 'then any \$N\s+\\subseteq \\Domain\{M\}\$ determines' 1 $rawTarget[$sub] 'setiap himpunan bagian tak kosong \$N \\subseteq \\Domain\{M\}\$ menentukan' 1
Assert-SourceCorrection 'isomorphism/codomain-function-interpretation' $rawSource[$iso] '\\Value\{t\}\{M''\}\[h \\circ s\] & = \\Assign\{f\}\{M\}\(' 1 $rawTarget[$iso] '\\Value\{t\}\{M''\}\[h \\circ s\] & = \\Assign\{f\}\{M''\}\(' 1
Assert-SourceCorrection 'isomorphism/missing-closing-parenthesis' $rawSource[$iso] 'h\(\\Assign\{f\}\{M\}\(\\Value\{t_1\}\{M\}\[s\], \\dots, \\Value\{t_n\}\{M\}\[s\]\) \\notag' 1 $rawTarget[$iso] 'h\(\\Assign\{f\}\{M\}\(\\Value\{t_1\}\{M\}\[s\], \\dots,\s*\\Value\{t_n\}\{M\}\[s\]\)\) \\notag' 1
Assert-SourceCorrection 'partial-iso/back-enumeration-index' $rawSource[$partial] 'n\+1 =2r\$' 1 $rawTarget[$partial] 'n\+1 =2r\+2\$' 1
Assert-SourceCorrection 'partial-iso/sequence-length-binder' $rawSource[$partial] 'sequences of equal length, by recursion on \$n\$ as follows:' 1 $rawTarget[$partial] 'barisan-barisan yang sama panjang, secara rekursif pada \$n\$ sebagai\s+berikut\. Misalkan kedua barisan tersebut mempunyai panjang~\$k\$\.' 1
Assert-SourceCorrection 'partial-iso/sequence-index-variable' $rawSource[$partial] '\$x_1\$, \\dots,~\$x_n\$' 1 $rawTarget[$partial] '\$x_1\$, \\dots,~\$x_k\$' 1
Assert-SourceCorrection 'partial-iso/free-variable-scope' $rawSource[$partial] 'for every \$!A\$ such that\s+\$\\QuantRank\{!A\} \\le n\$' 1 $rawTarget[$partial] 'bagi setiap \$!A\$ yang semua\s+variabel bebasnya tercantum dalam barisan yang bersesuaian dan sedemikian\s+sehingga \$\\QuantRank\{!A\} \\le n\$' 1
Assert-SourceCorrection 'partial-iso/finite-up-to-equivalence' $rawSource[$partial] '\$!T\^a_n\$ is finite, so we can\s+assume it is a single first-order' 1 $rawTarget[$partial] 'Hingga ekuivalensi\s+logis, himpunan ini hanya mempunyai berhingga banyak anggota; jadi, dengan\s+memilih wakil-wakil dan mengambil konjungsinya, kita dapat memperlakukan\s+\$!T\^a_n\$ sebagai satu' 1
Assert-SourceCorrection 'dlo/forth-domain-and-empty-cases' $rawSource[$dlo] 'Given \$a \\in \\Domain\{M_1\}\$, find \$b' 1 $rawTarget[$dlo] 'Jika unsur yang diberikan sudah berada dalam domain\s+fungsi parsial itu.*Jika fungsi parsial itu kosong' 1

# Reviewer-routed target-only wording corrections and rejected residues.
Assert-TargetReview 'reduct/raw-structure-to-struktur' $rawTarget[$reduct] '-struktur' 3 @('-structure')
Assert-TargetReview 'reduct/n-place-relation' $rawTarget[$reduct] 'relasi \$n\$-tempat' 1 @('relasi bertempat~\$n\$')
Assert-TargetReview 'theory/predicate-arity' $rawTarget[$theory] '!!\{predicate\} beraritas~2' 1 @('!!\{predicate\} bertempat~2')
Assert-TargetReview 'dlo/predicate-arity' $rawTarget[$dlo] '!!\{predicate\}~\$<\$ beraritas~2' 1 @('!!\{predicate\} bertempat~2')
Assert-TargetReview 'dlo/no-duplicated-merupakan-urutan' $rawTarget[$dlo] '\$\\Struct\{S\}\$ merupakan\s+urutan linear rapat tanpa titik ujung yang !!\{enumerable\}' 1 @('merupakan urutan merupakan','merupakan\s+!!a\{enumerable\} urutan')
Assert-TargetReview 'theory/enumerable-model-token-order' $rawTarget[$theory] 'mempunyai model yang\s+!!\{enumerable\}, sebut saja' 1 @('mempunyai !!a\{enumerable\}\s+model')
Assert-TargetReview 'dlo/existential-structure-token-order' $rawTarget[$dlo] 'terdapat\s+!!a\{structure\}~\$\\Struct\{S\}\$ yang !!\{enumerable\}' 1 @('terdapat\s+!!a\{enumerable\} !!\{structure\}')
Assert-TargetReview 'dlo/predicative-enumerable-token-order' $rawTarget[$dlo] 'urutan linear rapat tanpa titik ujung yang !!\{enumerable\}, sehingga' 1 @('merupakan\s+!!a\{enumerable\} urutan linear')

# Exact Indonesian terminology surfaces selected for this batch.
$allTarget=($units | ForEach-Object { $rawTarget[$_.Path] }) -join "`n"
$terms=[ordered]@{ 'model-theory'='Teori Model'; reduct='\breduk\b'; expansion='\bekspansi\w*\b'; substructure='sub!!\{structure\}'; extension='\bperluasan\b'; overspill='\b[Pp]eluapan\b'; 'elementary-equivalence'='ekuivalen secara elementer'; 'partial-isomorphism'='isomorfisme parsial'; 'back-and-forth'='sifat bolak-balik'; 'quantifier-rank'='peringkat kuantor'; 'dense-linear-order'='urutan linear rapat tanpa titik ujung' }
$termCounts=[ordered]@{ 'model-theory'=2; reduct=2; expansion=3; substructure=4; extension=5; overspill=1; 'elementary-equivalence'=2; 'partial-isomorphism'=6; 'back-and-forth'=2; 'quantifier-rank'=10; 'dense-linear-order'=5 }
foreach ($name in $terms.Keys) { Assert-RegexCount "terminology/$name" $allTarget $terms[$name] $termCounts[$name]; $terminologyClasses++ }
Assert-RegexCount 'terminology/forth-Maju' $allTarget '\bMaju\b' 4; $terminologyClasses++
Assert-RegexCount 'terminology/back-Mundur' $allTarget '\bMundur\b' 4; $terminologyClasses++

# Preserved upstream risk: the partial-function clause does not state that
# p(f^M(...)) is defined. This is evidence, not a silent target correction.
Assert-RegexCount 'risk/partial-function-definedness-source' $rawSource[$partial] 'then \$p\(\\Assign f M \(a_1, \\dots,a_n\)\)\s+= \\Assign f N' 1
Assert-RegexCount 'risk/partial-function-definedness-target-preserved' $rawTarget[$partial] 'maka \$p\(\\Assign f M \(a_1, \\dots,a_n\)\)\s+= \\Assign f N' 1
$riskClasses++

# Retracted false positive: \Sat/ is the intentional negative-satisfaction form.
Assert-RegexCount 'retraction/Sat-slash-source' $rawSource[$theory] '\\Sat/\{N\}\{\\lnot !A\}' 1
Assert-RegexCount 'retraction/Sat-slash-target' $rawTarget[$theory] '\\Sat/\{N\}\{\\lnot !A\}' 1
$retractionClasses++

Assert-Exact (-not [regex]::IsMatch($allTarget,'\\olfileid(?!\[id\])')) 'batch/all-file-identifiers-id'
Assert-Exact (-not [regex]::IsMatch($allTarget,'\\olchapter\[id\]|\\olpart\[id\]')) 'batch/no-locale-overload-on-chapter-or-part'
$validTokenPattern='!!(?:\^)?(?:a|A)?\{[^{}\r\n]+\}(?:s|d)?'; $withoutTokens=[regex]::Replace((Remove-TexComments $allTarget),$validTokenPattern,'')
Assert-Exact (-not [regex]::IsMatch($withoutTokens,'!!')) 'batch/all-semantic-token-forms-valid'

$englishPhrases=@('Model Theory','Basics of Model Theory','Reducts and Expansions','Isomorphic Structures','Partial Isomorphisms','Dense Linear Orders','Often it is useful','Suppose that','For every','If and only if','This establishes the Forth property','Complete the proof','The proof that','Given two structures','There are only finitely many')
$residueHits=0
foreach ($unit in $units) { $surface=Remove-NonReaderSurface $rawTarget[$unit.Path]; foreach ($phrase in $englishPhrases) { $n=([regex]::Matches($surface,[regex]::Escape($phrase),'IgnoreCase')).Count; if ($n -gt 0) { throw "English residue $($unit.Id): '$phrase' count=$n" }; $residueHits += $n } }
Assert-Exact ($residueHits -eq 0) 'batch/high-confidence-English-residue' 'hits=0'

Assert-Exact ($normalizationMatches -eq 7) 'batch/structural-normalization-count' 'count=7'
Assert-Exact ($sourceCorrectionClasses -eq 9) 'batch/source-correction-class-count' 'count=9'
Assert-Exact ($targetReviewClasses -eq 8) 'batch/target-review-class-count' 'count=8'
Assert-Exact ($terminologyClasses -eq 13) 'batch/terminology-class-count' 'count=13'
Assert-Exact ($riskClasses -eq 1) 'batch/preserved-risk-class-count' 'count=1'
Assert-Exact ($retractionClasses -eq 1) 'batch/false-positive-retraction-class-count' 'count=1'

# Filled after the first parser run, then frozen so a weakened parser or
# symmetric omission cannot create a false pass.
$expectedTotals=[ordered]@{ commands=942; environments=138; semantic_tokens=112; labels=23; references=20; citations=0; assets=0; imports=11; tagged_items=0; tag_conditionals=0; math_skeletons=480; math_environments=2; localized_file_ids=7; chapter_ids=1; part_ids=1 }
foreach ($entry in $expectedTotals.GetEnumerator()) { Assert-Exact ($totals[$entry.Key] -eq $entry.Value) "batch/frozen-total-$($entry.Key)" "count=$($entry.Value) actual=$($totals[$entry.Key])" }

$sourceDigest=Get-TextDigest @($sourceRecords); $targetDigest=Get-TextDigest @($targetRecords)
foreach ($unit in $units) { "TARGET_HASH $($unit.Id) $($unit.Path) $($unit.TargetHash)" }
"STRUCTURAL_TOTALS commands=$($totals.commands) environments=$($totals.environments) semantic_tokens=$($totals.semantic_tokens) labels=$($totals.labels) references=$($totals.references) citations=$($totals.citations) assets=$($totals.assets) imports=$($totals.imports) tagged_items=$($totals.tagged_items) tag_conditionals=$($totals.tag_conditionals) math_skeletons=$($totals.math_skeletons) math_environments=$($totals.math_environments) localized_file_ids=$($totals.localized_file_ids) chapter_ids=$($totals.chapter_ids) part_ids=$($totals.part_ids)"
"REVIEW_TOTALS source_corrections=$sourceCorrectionClasses structural_normalizations=$normalizationMatches target_review_classes=$targetReviewClasses terminology_classes=$terminologyClasses preserved_risk_classes=$riskClasses false_positive_retractions=$retractionClasses"
"BINDING_DIGESTS source_set_sha256=$sourceDigest target_set_sha256=$targetDigest config_sha256=$expectedConfigHash"
"MODEL_THEORY_BASICS_BATCH_REPLAY_OK files=$($units.Count) checks=$checks upstream=$expectedCommit closure=OLP-0182..OLP-0190"
