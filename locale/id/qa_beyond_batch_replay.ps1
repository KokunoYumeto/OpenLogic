$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$localeRoot = $PSScriptRoot
$repoRoot = [IO.Path]::GetFullPath((Join-Path $localeRoot '..\..'))
$controlRoot = [IO.Path]::GetFullPath((Join-Path $repoRoot '..\_control'))
$manifestPath = Join-Path $controlRoot 'OPENLOGIC_CLOSURE_MANIFEST_20260812.csv'
$expectedCommit = '9620cc73f9c8e0ad003c514a5d3748f29611c4c0'

$units = @(
    [pscustomobject]@{ Id='OLP-0174'; Path='content/first-order-logic/beyond/beyond.tex'; SourceBlob='7a0b6c6a0d1a2ccf275fe5a39f3f829aea2f79ce'; SourceHash='01c5b0b8dfff784fd345633ad6f9ec678b48cd6185a6912e8fc9ab317f61403e'; TargetHash='17f8888f566a7343ea8010d36760733e58aacf327e8e625c956b844557d2944c' }
    [pscustomobject]@{ Id='OLP-0175'; Path='content/first-order-logic/beyond/introduction.tex'; SourceBlob='1655fb97c2374dae9588534ffda4b56ee7f22e08'; SourceHash='84223ddeb7093a489e9130870be10bf99d6082762db58dff7763044c3ce6039e'; TargetHash='39ce6939d27fc4bc4a59296db357e10f78c56c67a3d91d3481ce59e89e325bc8' }
    [pscustomobject]@{ Id='OLP-0176'; Path='content/first-order-logic/beyond/many-sorted-logic.tex'; SourceBlob='a8116d41d5daffa8914dc037adcafb861e0164c5'; SourceHash='00d702a1e3ddd4f8e98ddb1f01b5ddffe140ce3e32a40acad54dbe1e4ba64f98'; TargetHash='271090bf667bf515694b76c0c26386fdbf748ae58234a7abbb8d1abb944a51ab' }
    [pscustomobject]@{ Id='OLP-0177'; Path='content/first-order-logic/beyond/second-order-logic.tex'; SourceBlob='35869f541efa77d83da0d7503da4cc3935dab56b'; SourceHash='c5a38313f00a864f10c9f7005a8f8ad4ef9ca2289690f0222f66cae6fa2af8cf'; TargetHash='5a5198b3092cbcb3f1e6d83a78b9b249375366378a338bb4862c15d9b23d0818' }
    [pscustomobject]@{ Id='OLP-0178'; Path='content/first-order-logic/beyond/higher-order-logic.tex'; SourceBlob='772c81c3ceb14c900069ded62cbe5705a0201bb9'; SourceHash='52968463dd9b903b6ad2bcf76b0cb5c71d222d2c439855672f5216fac8335692'; TargetHash='736af250df1818968ed5268a131063c472bf0515c7b3269b9d667b244baa8be3' }
    [pscustomobject]@{ Id='OLP-0179'; Path='content/first-order-logic/beyond/intuitionistic-logic.tex'; SourceBlob='e180ee5b40e07fe9100801d558fb6442334a95ea'; SourceHash='3230d39434d6ecdbf0e6cd7e0c8b1df843b991e8e2106b1ecd91db9ea4f94cc0'; TargetHash='e46103ab6f189be692f5002efbc4de07152ffbf47b844e694e4a3bf038c82991' }
    [pscustomobject]@{ Id='OLP-0180'; Path='content/first-order-logic/beyond/modal-logics.tex'; SourceBlob='db401dc5c88a75c5a9760aa2bb2ea99fdaa08d3b'; SourceHash='3bfc4f07de2027fd339884563522915e040c5105207a857a65e2b033fef4a1d1'; TargetHash='dc6f7fd8574b02b6a47662a4b392d9f093724c87bc2357d7a8bd09c3f3812eab' }
    [pscustomobject]@{ Id='OLP-0181'; Path='content/first-order-logic/beyond/other-logics.tex'; SourceBlob='0c969c04de99d55d27ab292c9d7b39a8b9035300'; SourceHash='bc7394b6a16921b5a7b2dc8129b1a6c8a2b2900dc3a30b886a06ab2028ea7691'; TargetHash='2888bc71999cadd9c4953e8a107f84c1e8c469117ca06468e54a3aa8e8a58df0' }
)

$checks = 0
$normalizationMatches = 0
$correctionClasses = 0
$reviewAssertions = 0
$riskAssertions = 0
$retractionAssertions = 0
$totals = [ordered]@{ commands=0; environments=0; semantic_tokens=0; labels=0; references=0; citations=0; assets=0; imports=0; tagged_items=0; tag_conditionals=0; math_skeletons=0; math_environments=0; localized_file_ids=0; chapter_ids=0 }

function Normalize-Newlines([string]$Text) { return ($Text -replace "`r`n", "`n" -replace "`r", "`n") }
function Get-Sha256([string]$Path) { return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant() }
function Get-BytesSha256([byte[]]$Bytes) { $sha=[Security.Cryptography.SHA256]::Create(); try { return ([BitConverter]::ToString($sha.ComputeHash($Bytes))).Replace('-','').ToLowerInvariant() } finally { $sha.Dispose() } }
function Get-TextDigest([string[]]$Items) { return Get-BytesSha256 ([Text.Encoding]::UTF8.GetBytes(($Items -join "`n"))) }
function Assert-Exact([bool]$Condition,[string]$Name,[string]$Detail='') { if(-not $Condition){throw "FAIL $Name $Detail"}; $script:checks++; if($Detail){"PASS $Name $Detail"}else{"PASS $Name"} }
function Assert-Sequence([string]$Name,[object[]]$Expected,[object[]]$Actual) { if($Expected.Count -ne $Actual.Count){throw "$Name count mismatch source=$($Expected.Count) target=$($Actual.Count)"}; for($i=0;$i -lt $Expected.Count;$i++){if([string]$Expected[$i] -cne [string]$Actual[$i]){throw "$Name mismatch index=$i SOURCE=$($Expected[$i]) TARGET=$($Actual[$i])"}}; $script:checks++; "PASS $Name count=$($Actual.Count)" }
function Assert-RegexCount([string]$Name,[string]$Text,[string]$Pattern,[int]$Expected) { $n=([regex]::Matches($Text,$Pattern,'Singleline')).Count; Assert-Exact ($n -eq $Expected) $Name "count=$n" }

function Invoke-GitBytes([string]$WorkingDirectory,[string[]]$Arguments) {
    $start=[Diagnostics.ProcessStartInfo]::new(); $start.FileName='git'; $start.WorkingDirectory=$WorkingDirectory; $start.UseShellExecute=$false; $start.RedirectStandardOutput=$true; $start.RedirectStandardError=$true
    foreach($a in $Arguments){[void]$start.ArgumentList.Add($a)}
    $p=[Diagnostics.Process]::Start($start); $memory=[IO.MemoryStream]::new()
    try { $copy=$p.StandardOutput.BaseStream.CopyToAsync($memory); $err=$p.StandardError.ReadToEndAsync(); [void]$copy.GetAwaiter().GetResult(); $errorText=$err.GetAwaiter().GetResult(); $p.WaitForExit(); if($p.ExitCode -ne 0){throw "git failed: $errorText"}; return ,$memory.ToArray() } finally { $memory.Dispose(); $p.Dispose() }
}

function Get-BraceBalance([string]$Text) {
    $balance=0; $comment=$false
    for($i=0;$i -lt $Text.Length;$i++){ $c=$Text[$i]; if($comment){if($c -eq "`n"){$comment=$false};continue}; $slashes=0; for($j=$i-1;$j -ge 0 -and $Text[$j] -eq '\';$j--){$slashes++}; $escaped=(($slashes%2)-eq 1); if($c -eq '%' -and -not $escaped){$comment=$true;continue}; if($escaped){continue}; if($c -eq '{'){$balance++}elseif($c -eq '}'){$balance--}; if($balance -lt 0){return $balance} }; return $balance
}
function Remove-TexComments([string]$Text) {
    $b=[Text.StringBuilder]::new(); foreach($line in ((Normalize-Newlines $Text) -split "`n",0,'SimpleMatch')){ $cut=-1; for($i=0;$i -lt $line.Length;$i++){if($line[$i] -ne '%'){continue};$slashes=0;for($j=$i-1;$j -ge 0 -and $line[$j] -eq '\';$j--){$slashes++};if(($slashes%2)-eq 0){$cut=$i;break}};if($cut -ge 0){[void]$b.Append($line.Substring(0,$cut))}else{[void]$b.Append($line)};[void]$b.Append("`n") }; return $b.ToString()
}
function Get-Sequence([string]$Text,[string]$Pattern,[string]$Group='value') { return @([regex]::Matches($Text,$Pattern,'Singleline')|ForEach-Object{$_.Groups[$Group].Value}) }
function Replace-LiteralExact([string]$Text,[string]$Old,[string]$New,[int]$Expected,[string]$Name) { $n=([regex]::Matches($Text,[regex]::Escape($Old))).Count; if($n-ne$Expected){throw "$Name normalization expected=$Expected actual=$n"};$script:normalizationMatches+=$n;return $Text.Replace($Old,$New) }
function Get-CorrectedSource([string]$Path,[string]$Text) {
    $r=Normalize-Newlines $Text
    if($Path -ceq 'content/first-order-logic/beyond/second-order-logic.tex'){
        $r=Replace-LiteralExact $r '\Obj{R}{t_1,\dots,t_k}' '\Atom{R}{t_1,\dots,t_k}' 1 'second-order/atomic-relation-macro'
        $r=Replace-LiteralExact $r 's(x) = s(y) \lif x = y' "x' = y' \lif x = y" 1 'second-order/successor-injectivity'
    }
    if($Path -ceq 'content/first-order-logic/beyond/higher-order-logic.tex'){
        $r=Replace-LiteralExact $r 'for any~$x$ of type~$\sigma$' 'for any~$x$ of type~$\tau$' 1 'higher-order/lambda-binder-type'
    }
    return $r
}
function Replace-ProseArgument([string]$Text,[string]$Command) {
    $needle="\$Command{";$b=[Text.StringBuilder]::new();$i=0
    while($i-lt$Text.Length){if(($i+$needle.Length-le$Text.Length)-and($Text.Substring($i,$needle.Length)-ceq$needle)){[void]$b.Append("\$Command{<TEXT>}");$i+=$needle.Length;$d=1;while($i-lt$Text.Length-and$d-gt 0){if($Text[$i]-eq'\'-and$i+1-lt$Text.Length){$i+=2;continue};if($Text[$i]-eq'{'){$d++}elseif($Text[$i]-eq'}'){$d--};$i++};if($d-ne0){throw "Unbalanced \$Command"};continue};[void]$b.Append($Text[$i]);$i++};return $b.ToString()
}
function Normalize-Math([string]$Text) { $r=$Text;foreach($c in @('text','textrm','intertext','emph')){$r=Replace-ProseArgument $r $c};return [regex]::Replace($r,'[\s~]+','') }
function Get-MathSkeletons([string]$Text) { $items=[Collections.Generic.List[object]]::new();foreach($m in [regex]::Matches($Text,'(?<!\\)\$(.*?)(?<!\\)\$','Singleline')){$items.Add([pscustomobject]@{Index=$m.Index;Value=('INLINE:'+(Normalize-Math $m.Value))})};foreach($m in [regex]::Matches($Text,'\\\[(.*?)\\\]','Singleline')){$items.Add([pscustomobject]@{Index=$m.Index;Value=('DISPLAY:'+(Normalize-Math $m.Value))})};return @($items|Sort-Object Index|ForEach-Object{$_.Value}) }
function Get-MathEnvironmentStructures([string]$Text) { $items=[Collections.Generic.List[object]]::new();foreach($e in @('align','align*','multline','multline*','equation','equation*','aligned','cases')){$q=[regex]::Escape($e);foreach($m in [regex]::Matches($Text,"\\begin\{$q\}(?:\[[^\]]*\])?(?<body>.*?)\\end\{$q\}",'Singleline')){$body=$m.Groups['body'].Value;foreach($c in @('text','textrm','intertext')){$body=Replace-ProseArgument $body $c};$items.Add([pscustomobject]@{Index=$m.Index;Value=($e+':'+(Normalize-Math $body))})}};return @($items|Sort-Object Index|ForEach-Object{$_.Value}) }
function Get-CommandSequence([string]$Text) { return @(Get-Sequence $Text '(?<value>\\[A-Za-z@]+|\\.)') }
function Get-SemanticTokenNames([string]$Text) { return @([regex]::Matches($Text,'!!(?:\^)?(?:a|A)?\{(?<value>[^{}]+)\}(?:s|d)?','Singleline')|ForEach-Object{[regex]::Replace($_.Groups['value'].Value,'\s+',' ')}|Sort-Object) }
function Remove-NonReaderSurface([string]$Text) { $r=Remove-TexComments $Text;$r=[regex]::Replace($r,'\\\[.*?\\\]','','Singleline');$r=[regex]::Replace($r,'(?<!\\)\$.*?(?<!\\)\$','','Singleline');$r=[regex]::Replace($r,'!!(?:\^)?(?:a|A)?\{[^{}]+\}(?:s|d)?','');return $r }

$type=@(& git -C $repoRoot cat-file -t $expectedCommit 2>$null)
Assert-Exact (($LASTEXITCODE-eq0)-and$type.Count-eq1-and$type[0]-ceq'commit') 'frozen-source-commit-object' $expectedCommit
Assert-Exact (Test-Path -LiteralPath $manifestPath) 'closure-manifest-present' $manifestPath
$manifest=Import-Csv -LiteralPath $manifestPath
$batch=@($manifest|Where-Object{[int]$_.stable_order-ge174-and[int]$_.stable_order-le181}|Sort-Object{[int]$_.stable_order})
Assert-Exact ($batch.Count-eq8) 'manifest-batch-count' 'count=8'
Assert-Sequence 'manifest/ordered-closure-ids' @($units.Id) @($batch.closure_id)

$literal=[ordered]@{ environments='(?<value>\\(?:begin|end)\{[^{}]+\})';labels='(?<value>\\ollabel\{[^{}]+\})';references='(?<value>\\(?:olref|Olref)(?:\[[^\]]*\]){0,3}\{[^{}]+\}|\\(?:cref|Cref)\{[^{}]+\})';citations='(?<value>\\cite[a-zA-Z]*\{[^{}]+\})';assets='(?<value>\\olasset(?:\[[^\]]*\])?\{[^{}]+\})';imports='(?<value>\\olimport\*?(?:\[[^\]]*\])?\{[^{}]+\})';tagged_items='(?<value>\\tagitem\{[^{}]+\}|\\tagprob\{[^{}]+\}|\\tagendprob\b)';tag_conditionals='(?<value>\\iftag\{[^{}]+\})' }
$rawSource=@{};$rawTarget=@{};$sourceRecords=[Collections.Generic.List[string]]::new();$targetRecords=[Collections.Generic.List[string]]::new()

for($i=0;$i-lt$units.Count;$i++){
    $u=$units[$i];$row=$batch[$i];$sourcePath=Join-Path $repoRoot ($u.Path-replace'/','\');$targetRel="locale/id/$($u.Path)";$targetPath=Join-Path $repoRoot ($targetRel-replace'/','\')
    Assert-Exact ($row.closure_id-ceq$u.Id-and[int]$row.stable_order-eq(174+$i)-and$row.source_commit-ceq$expectedCommit-and$row.source_path-ceq$u.Path-and$row.source_sha256.ToLowerInvariant()-ceq$u.SourceHash-and$row.target_path-ceq$targetRel-and$row.closure_included-ceq'true'-and$row.canonical_reader_reachable-ceq'true') "$($u.Id)/manifest-binding"
    Assert-Exact (Test-Path -LiteralPath $sourcePath) "$($u.Id)/source-present"
    Assert-Exact (Test-Path -LiteralPath $targetPath) "$($u.Id)/target-present"
    Assert-Exact ((Get-Sha256 $sourcePath)-ceq$u.SourceHash) "$($u.Id)/source-worktree-hash" $u.SourceHash
    $blob=@(& git -C $repoRoot rev-parse --verify "$expectedCommit`:$($u.Path)" 2>$null);Assert-Exact ($LASTEXITCODE-eq0-and$blob.Count-eq1-and$blob[0]-ceq$u.SourceBlob) "$($u.Id)/source-git-object" $u.SourceBlob
    $sourceRaw=Normalize-Newlines ([Text.Encoding]::UTF8.GetString((Invoke-GitBytes $repoRoot @('cat-file','blob',$u.SourceBlob))));$workRaw=Normalize-Newlines ([IO.File]::ReadAllText($sourcePath));Assert-Exact ($sourceRaw-ceq$workRaw) "$($u.Id)/source-content-binding" 'newline-normalized=true'
    Assert-Exact ((Get-Sha256 $targetPath)-ceq$u.TargetHash) "$($u.Id)/target-hash" $u.TargetHash
    $targetRaw=Normalize-Newlines ([IO.File]::ReadAllText($targetPath));$rawSource[$u.Path]=$sourceRaw;$rawTarget[$u.Path]=$targetRaw
    $source=Remove-TexComments (Get-CorrectedSource $u.Path $sourceRaw);$target=Remove-TexComments $targetRaw
    Assert-Exact ((Get-BraceBalance $sourceRaw)-eq0) "$($u.Id)/source-brace-balance";Assert-Exact ((Get-BraceBalance $targetRaw)-eq0) "$($u.Id)/target-brace-balance"
    $a=@(Get-CommandSequence $source);$b=@(Get-CommandSequence $target);Assert-Sequence "$($u.Id)/commands" $a $b;$totals.commands+=$b.Count
    foreach($name in $literal.Keys){$a=@(Get-Sequence $source $literal[$name]);$b=@(Get-Sequence $target $literal[$name]);Assert-Sequence "$($u.Id)/$name" $a $b;$totals[$name]+=$b.Count}
    $a=@(Get-SemanticTokenNames $source);$b=@(Get-SemanticTokenNames $target);Assert-Sequence "$($u.Id)/semantic-token-base-multiset" $a $b;$totals.semantic_tokens+=$b.Count
    $a=@(Get-MathSkeletons $source);$b=@(Get-MathSkeletons $target);Assert-Sequence "$($u.Id)/math-skeletons" $a $b;$totals.math_skeletons+=$b.Count
    $a=@(Get-MathEnvironmentStructures $source);$b=@(Get-MathEnvironmentStructures $target);Assert-Sequence "$($u.Id)/math-environments" $a $b;$totals.math_environments+=$b.Count
    $a=@([regex]::Matches($source,'\\olfileid(?:\[[^\]]+\])?'));$b=@([regex]::Matches($target,'\\olfileid\[id\]'));Assert-Exact ($a.Count-eq$b.Count) "$($u.Id)/localized-file-ids" "count=$($b.Count)";$totals.localized_file_ids+=$b.Count
    $a=@([regex]::Matches($source,'\\olchapter(?:\[[^\]]+\])?'));$b=@([regex]::Matches($target,'\\olchapter(?!\[)'));Assert-Exact ($a.Count-eq$b.Count) "$($u.Id)/chapter-ids" "count=$($b.Count)";$totals.chapter_ids+=$b.Count
    $sourceRecords.Add("$($u.Id)|$($u.SourceBlob)|$($u.SourceHash)|$($u.Path)");$targetRecords.Add("$($u.Id)|$($u.TargetHash)|$targetRel")
}

$second='content/first-order-logic/beyond/second-order-logic.tex';$higher='content/first-order-logic/beyond/higher-order-logic.tex';$intuition='content/first-order-logic/beyond/intuitionistic-logic.tex';$modal='content/first-order-logic/beyond/modal-logics.tex'
Assert-RegexCount 'correction/source-atomic-relation-macro' $rawSource[$second] '\\Obj\{R\}\{t_1,\\dots,t_k\}' 1;Assert-RegexCount 'correction/target-no-wrong-atomic-relation-macro' $rawTarget[$second] '\\Obj\{R\}\{t_1,\\dots,t_k\}' 0;Assert-RegexCount 'correction/target-atomic-relation-macro-total' $rawTarget[$second] '\\Atom\{R\}\{t_1,\\dots,t_k\}' 2;$correctionClasses++
Assert-RegexCount 'correction/source-successor-injectivity' $rawSource[$second] 's\(x\) = s\(y\) \\lif x = y' 1;Assert-RegexCount 'correction/target-successor-injectivity' $rawTarget[$second] "x' = y' \\lif x = y" 1;$correctionClasses++
Assert-RegexCount 'correction/source-lambda-binder-type' $rawSource[$higher] 'for any~\$x\$ of type~\$\\sigma\$' 1;Assert-RegexCount 'correction/target-lambda-binder-type' $rawTarget[$higher] 'untuk setiap~\$x\$ bertipe~\$\\tau\$' 1;$correctionClasses++

Assert-RegexCount 'review/logisisme' (($units|ForEach-Object{$rawTarget[$_.Path]})-join"`n") '\{\\em logisisme\}' 1;$reviewAssertions++
Assert-RegexCount 'review/perikutan' $rawTarget[$second] '\\Entails\$ menyatakan perikutan' 1;$reviewAssertions++
Assert-RegexCount 'review/non-gendered-married-pair' $rawTarget['content/first-order-logic/beyond/many-sorted-logic.tex'] 'pasangan menikah multinasional' 1;Assert-RegexCount 'review/no-gendered-spouse-wording' $rawTarget['content/first-order-logic/beyond/many-sorted-logic.tex'] '\b(?:suami|istri)\b' 0;$reviewAssertions++
Assert-RegexCount 'terminology/many-sorted-logic' (($units|ForEach-Object{$rawTarget[$_.Path]})-join"`n") 'logika banyak-sorta' 4;$reviewAssertions++
Assert-RegexCount 'terminology/forcing-relation' $rawTarget[$intuition] 'Relasi pemaksaan' 1;$reviewAssertions++
Assert-RegexCount 'terminology/default-logic' $rawTarget['content/first-order-logic/beyond/other-logics.tex'] 'Logika default' 1;$reviewAssertions++

Assert-RegexCount 'risk/equivalent-schema-item-1-source' $rawSource[$intuition] '\\item \$\(\\lnot !A \\lif \\lfalse\) \\lif !A\$\.' 1;Assert-RegexCount 'risk/equivalent-schema-item-3-source' $rawSource[$intuition] '\\item \$\\lnot \\lnot !A \\lif !A\$' 1;Assert-RegexCount 'risk/equivalent-schema-item-1-target-preserved' $rawTarget[$intuition] '\\item \$\(\\lnot !A \\lif \\lfalse\) \\lif !A\$\.' 1;Assert-RegexCount 'risk/equivalent-schema-item-3-target-preserved' $rawTarget[$intuition] '\\item \$\\lnot \\lnot !A \\lif !A\$' 1;$riskAssertions++
Assert-RegexCount 'risk/log3-witness-source' $rawSource[$intuition] 'take \$a = \\sqrt\{3\}\$\s+and \$b = \\log_3 4\$' 1;Assert-RegexCount 'risk/log3-witness-target-preserved' $rawTarget[$intuition] 'ambil \$a = \\sqrt\{3\}\$ dan \$b = \\log_3 4\$' 1;$riskAssertions++

Assert-RegexCount 'retraction/iterated-binder-ellipsis-source' $rawSource[$second] '\\lforall\[x_1 \\dots\]\[\\lforall\[x_k\]' 1;Assert-RegexCount 'retraction/iterated-binder-ellipsis-target' $rawTarget[$second] '\\lforall\[x_1 \\dots\]\[\\lforall\[x_k\]' 1;$retractionAssertions++
Assert-RegexCount 'retraction/R-not-free-source' $rawSource[$second] '\$R\$ is not a free variable' 1;Assert-RegexCount 'retraction/R-not-free-target' $rawTarget[$second] 'dengan \$R\$ bukan\s+variabel bebas' 1;$retractionAssertions++
Assert-RegexCount 'retraction/S5-universal-source' $rawSource[$modal] 'accessibility relation is \{\\em universal\}' 1;Assert-RegexCount 'retraction/S5-universal-target' $rawTarget[$modal] 'relasi aksesibilitasnya \{\\em universal\}' 1;$retractionAssertions++

$allTarget=($units|ForEach-Object{$rawTarget[$_.Path]})-join"`n"
Assert-Exact (-not [regex]::IsMatch($allTarget,'\\olfileid(?!\[id\])')) 'batch/all-file-identifiers-id'
$phrases=@('Beyond first-order logic','The language of many-sorted logic','The language of second-order logic','Intuitionistic logic is designed','Modal logic comes in many flavors','Default logic and nonmonotonic logic')
$hits=0;foreach($u in $units){$surface=Remove-NonReaderSurface $rawTarget[$u.Path];foreach($p in $phrases){$n=([regex]::Matches($surface,[regex]::Escape($p),'IgnoreCase')).Count;if($n-gt0){throw "English residue $($u.Id): $p"};$hits+=$n}};Assert-Exact ($hits-eq0) 'batch/untranslated-reader-prose' 'hits=0'
Assert-Exact ($normalizationMatches-eq3) 'batch/source-normalization-count' 'count=3';Assert-Exact ($correctionClasses-eq3) 'batch/source-correction-class-count' 'count=3';Assert-Exact ($reviewAssertions-eq6) 'batch/review-assertion-class-count' 'count=6';Assert-Exact ($riskAssertions-eq2) 'batch/source-risk-class-count' 'count=2';Assert-Exact ($retractionAssertions-eq3) 'batch/false-positive-retraction-class-count' 'count=3'

# Freeze the complete parser aggregate so weakening a parser or symmetrically
# dropping source and target objects cannot create a false pass.
$expectedTotals=[ordered]@{ commands=618; environments=56; semantic_tokens=112; labels=0; references=0; citations=0; assets=0; imports=7; tagged_items=0; tag_conditionals=0; math_skeletons=334; math_environments=3; localized_file_ids=7; chapter_ids=1 }
foreach($entry in $expectedTotals.GetEnumerator()){Assert-Exact ($totals[$entry.Key]-eq$entry.Value) "batch/frozen-total-$($entry.Key)" "count=$($entry.Value) actual=$($totals[$entry.Key])"}

$sourceDigest=Get-TextDigest @($sourceRecords);$targetDigest=Get-TextDigest @($targetRecords)
foreach($u in $units){"TARGET_HASH $($u.Id) $($u.Path) $($u.TargetHash)"}
"STRUCTURAL_TOTALS commands=$($totals.commands) environments=$($totals.environments) semantic_tokens=$($totals.semantic_tokens) labels=$($totals.labels) references=$($totals.references) citations=$($totals.citations) assets=$($totals.assets) imports=$($totals.imports) tagged_items=$($totals.tagged_items) tag_conditionals=$($totals.tag_conditionals) math_skeletons=$($totals.math_skeletons) math_environments=$($totals.math_environments) localized_file_ids=$($totals.localized_file_ids) chapter_ids=$($totals.chapter_ids)"
"REVIEW_TOTALS source_corrections=$correctionClasses correction_occurrences=3 structural_normalizations=$normalizationMatches review_classes=$reviewAssertions source_risk_classes=$riskAssertions false_positive_retractions=$retractionAssertions"
"BINDING_DIGESTS source_set_sha256=$sourceDigest target_set_sha256=$targetDigest"
"BEYOND_BATCH_REPLAY_OK files=$($units.Count) checks=$checks upstream=$expectedCommit closure=OLP-0174..OLP-0181"
