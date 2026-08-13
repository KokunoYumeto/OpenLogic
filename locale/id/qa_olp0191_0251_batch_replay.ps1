$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$localeRoot = $PSScriptRoot
$repoRoot = [IO.Path]::GetFullPath((Join-Path $localeRoot '..\..'))
$controlRoot = [IO.Path]::GetFullPath((Join-Path $repoRoot '..\_control'))
$manifestPath = Join-Path $controlRoot 'OPENLOGIC_CLOSURE_MANIFEST_20260812.csv'
$configPath = Join-Path $localeRoot 'open-logic-config.sty'
$expectedCommit = '9620cc73f9c8e0ad003c514a5d3748f29611c4c0'
$expectedConfigHash = '84b09e09ccfa1e03f45ef8cf0de20a3525f9c196317ee4f4a675ab27f1f0cbdd'
$expectedManifestBindingDigest = '610ece178c3fcb5ee8fdbb92d697c80c4279e058ecee83c1ae7df7d0511bee4c'
$expectedTargetBindingDigest = '45df77e61c17a67852cef0dc390cbe81a22c09a980e3c9a2e3e47c2c27dababd'
$expectedStructuralDigest = '590d328334aa9b397ad3c76227c73b982a342bebd47694dadb940959bfbd0593'
$expectedReviewDigest = '4757ab53edae353cb016bb1e96ee5d65c0e603677169fb1ddb47cc7cdf8acd9f'

# Final live target-byte bindings. Source paths and source hashes are bound
# separately to the frozen closure-manifest subset and its digest below.
$targetBindings = @'
Id,TargetHash,TargetBytes
OLP-0191,9ac0ba3945f0f8a0d2c7517eb1e502c119d34ae7a730327ea0a72d9f6af5cdb3,377
OLP-0192,f44e88d609c63b6aee745695e95ad2436f67be73122cc5c6d5da6ba5f1e2ab84,3526
OLP-0193,ba088247a64abe988f2ba8fe573645aa4cf479e489394fd2908ad33236478381,8498
OLP-0194,9db7cabfc574cc05fab3c6db3c6dd177fedec1085d23731dfad282bad90e98b5,5682
OLP-0195,cac0c778335ce4f67fb7b351b2deaa8e9829038441dd910988ecb8050000e9d8,8451
OLP-0196,cc7ef489662e2f913627d9be0589f68c3ca052745e999105100c6dceca79632c,11657
OLP-0197,0264a073e61750ce378a0574cc77c98f52fde7b8866a489629e792c2b5fc3d92,5043
OLP-0198,4bbe8de43d63b02f1d34de6f2a3b70eaf59db3f1390124c7f3343d58ac6fc3d5,308
OLP-0199,121b08b2d99f0ecebf2bac69a29644e6b9ccd4dcd2e2963453470c413f704fc4,1024
OLP-0200,f813ef7b6ac9302b8c95f674d4f33827ec56d1e29146a2a649f1a255cda9db8a,5238
OLP-0201,d2b10e2a733d48b06bcc572320b3e122d8995c341973c888d23ec2062ea8a62f,10126
OLP-0202,c0c466aed501ae19e634606261277b753e1c189e269b8d5420ab59ecaf654d69,5437
OLP-0203,ea60647bee250e5892147fe21d8176d4f9f30292d57c7541e83f4dffb50878d2,304
OLP-0204,82db35bcab0e64a9200c5555b2d46cdc4d2e01ea2d6ea9c3271ad05435b21f87,798
OLP-0205,11692de25a77e39be3b9039f1a6bf6f0fcea9f89767b213ded890e5131aeca61,7061
OLP-0206,4ac6fc8aaef2cf6494e992e8018ea739b3fe3d52eb61fbb404cc39745a739d51,6065
OLP-0207,7a1805201b26b6c5affaa1946946e6a9efb9595f30e56299191999caae64c99a,6785
OLP-0208,6cd2d2b92ed78538d1cfa992c89dd950d5d06031c20bd7d7e5f66b397b59ecb9,553
OLP-0209,610adbb34caac242664e780b1d709928c51c04fd8e717e91f42b7c244414c1b7,989
OLP-0210,ae17945cd80becf51885e4a39b4f9fb60015e02f01b513a2ec975447f1ae44a1,2982
OLP-0211,4e651120695800480d67b2db90300a33ec5f388b2fa7a206d17613306e3b9e13,6247
OLP-0212,dd992550253f1feddd0951c545ae309a4b4781de4bd2e8c1f8dd0712e043d80b,3728
OLP-0213,aab48ec733e9f3daa58721215f2a15c330077c67455d9347c3209e09b3fe0f65,6306
OLP-0214,7a40c15cf26721ecfc4063307cadce211184c8c710027d63bf75ae1b9de6d9bb,2265
OLP-0215,8325b94b14c988db80a9e48fe0ee0a99132aa1131898e5ba2735ebff90f9c48d,1897
OLP-0216,de9d2a764c7f611a8882c6b2efd6809d3fb89ee9d58fea562471715d4e400282,6128
OLP-0217,8ebdfa0064852f7506fc26fc9da47e04dc97a16b0f035215365fabbc1372fe9e,5901
OLP-0218,f04c6e560379cd17bee782acf4ba6228af21c2a2943b5873e3bad93688c2b991,2840
OLP-0219,cd6bef4686c5b66ac5a33c9adb77caa497047057da087e96b026dc5677b83342,3928
OLP-0220,8a0c136363e88b1e73a3714826b83c23d96f8e08a07adddabd5a13e2bc37a4f8,7243
OLP-0221,e22bbf144d44a920adea44810d41bc2d900b385347f2a6887b1ba2a9de8e4b87,3672
OLP-0222,513d7ba221b70f6355ebf8ace0682057246d552666316e77aab464e23ef6f4f3,2796
OLP-0223,5245dbc612e4b4d2641675a9dbc8270327157ea9291258ad284a9eda9483ecac,4763
OLP-0224,8de010eec51546b77da12a87ab0976ca355046579a58d10220f98a729a8f1802,5613
OLP-0225,ef18e0d75799f75ea92aa430900f2cc960af58f84e442f9c9b0623e438a28083,2008
OLP-0226,3c267b767384e08962a2a0f7cd31e5597f7680ee641e80b63d954f0eb6c94cf8,3166
OLP-0227,49d2d404427deffe640aca925c091b1dfb863cc80ceb2f2f93dae7294ce38ff9,1674
OLP-0228,60c81dd188837c4c5c9a4c1c0305c03b693db6ae5df765980774742c5d2aa20a,959
OLP-0229,3411adc134f95db16450442ad7e09a16ab91e210bd93557237756babd2564c35,3679
OLP-0230,091ece3b1d3138e57559aab9b14a1ba0bfd812b31eb35eace152867f399dd353,2020
OLP-0231,72663a6710c6efcf97f060f4fdce855507ecb4757acb23c120907407cb5af742,4227
OLP-0232,9dd211c165d8433b9222d269f17d280ba1bc111961182ce2cc0c819887dc609a,1665
OLP-0233,b2af6ef13c71a34d8697e658fe4ac8a83542db4a379f2a0ce97ac3814f168411,1715
OLP-0234,e014fe981b9afb21ff6dce349e38e100e3b1b94c499de967160414047484740b,1964
OLP-0235,035bbfc8d873b547dc83762051fde46477c040994bc90a197807090f740a112a,3980
OLP-0236,389825176e4c7f43e59468596ebc010022522a06f54edd3cc5366dd50aa628cc,2932
OLP-0237,0b8f311b4a9996bd9c009d57880488231936bc9a5841df91ea10eeea60c0c2cd,1398
OLP-0238,47019d77d9ab865668e627d8eabdc753b203edae8c550a1d754c482be5632c57,1735
OLP-0239,d7584e3b135f948299c1f92dbecfe2874607e4cd597b9f9c0214a9d86ebfc58b,6982
OLP-0240,b16225df4fa0327293c8b024ccc2b1114b217a3725ea7f2fb81b15f3ce88fb10,2417
OLP-0241,32964c87b306b2ec19f3b024636c8ea9f2defdbf5feccb6da26bbf042b77637b,3408
OLP-0242,a1c52e3d76ba97ac74108864cfc1a1fb0a47d974fa54765f9319e86b32876643,2398
OLP-0243,701a3d9f5a6ddae793e519e7445930ea2cabf4d6c21bd21894adadca115f3af0,3457
OLP-0244,2ae07d0b8f70ea9e4be1774abdca73deaef77fb853807736ee27e0f1f5a5904c,4455
OLP-0245,a31f3e187a7dbee8cea007fdc54b45caf70ad3d4f5de134f1f75a4cda832cb8f,2129
OLP-0246,8e3340444bd139623c53a91db95bf91449c76d934fe2bfcd95f5ad74443a9f70,2846
OLP-0247,ca777687db237b348925ccc94243badb3006f4e40414d4cd33f2da0e22bb473b,1886
OLP-0248,83879cfec786296457c93497f0467a1fee8a27c2dd404e7d8fc467839d0f724a,6170
OLP-0249,40be61b749c841a1c4d87e9735e27826e415b6464c9ef1fa61542d42be92398f,8448
OLP-0250,d35c27fad251c1c1cfe60a949359267eb1d398fe68301a5d279f6d2459a1ef77,3040
OLP-0251,833dfff9e92c18bfd23bc485983153f7b76a6fc1282ae3cd58000082f9b6e296,2022
'@ | ConvertFrom-Csv

# These exact mismatch sets are the path-scoped normalization boundary.
# Outside these IDs, ordered source and target sequences must be identical.
$expectedMismatch = [ordered]@{
    commands = @('OLP-0194','OLP-0196','OLP-0200','OLP-0201','OLP-0202','OLP-0205','OLP-0206','OLP-0207','OLP-0226','OLP-0239','OLP-0247','OLP-0248','OLP-0249','OLP-0250','OLP-0251')
    semantic_tokens = @('OLP-0202','OLP-0205','OLP-0206','OLP-0207')
    math_segments = @('OLP-0192','OLP-0193','OLP-0194','OLP-0196','OLP-0197','OLP-0200','OLP-0201','OLP-0202','OLP-0205','OLP-0206','OLP-0207','OLP-0211','OLP-0212','OLP-0213','OLP-0216','OLP-0217','OLP-0218','OLP-0219','OLP-0220','OLP-0221','OLP-0222','OLP-0224','OLP-0226','OLP-0232','OLP-0235','OLP-0236','OLP-0239','OLP-0240','OLP-0241','OLP-0242','OLP-0243','OLP-0245','OLP-0247','OLP-0248','OLP-0250','OLP-0251')
    math_environments = @('OLP-0193','OLP-0194','OLP-0195','OLP-0197','OLP-0217','OLP-0219','OLP-0220','OLP-0221','OLP-0222','OLP-0249')
}

$auditFindings = @(
    'OLP-0191..OLP-0207|PASS|independent paragraph-formula-identifier-TeX replay|zero unresolved target defects after normal-logic and negated-satisfaction repairs',
    'OLP-0208..OLP-0251|PASS|independent recursive-functions and computability-theory replay|zero unresolved target defects'
)

$correctionClasses = @(
    'OLP-0192|qualify nonstandard-element claim to arithmetic models; restore OPrf witness',
    'OLP-0193|remove stray leading equals; correct range/domain wording',
    'OLP-0194|repair converse qualification, M/M^c identifiers, empty finite-subset compactness case, and countable-model conclusion',
    'OLP-0195|repair K case y=a and L expression b nsplus a',
    'OLP-0196|repair bracket, zero predecessor scope, nonstandard-block scope/order, nsplus notation, and countability hypothesis',
    'OLP-0197|repair comprehension binder, explicit bijection, and Tennenbaum up-to-isomorphism scope',
    'OLP-0200|replace upstream delta typo by H',
    'OLP-0201|prime enumerated languages; add fallback assignments; repair language macros, transport argument, and structure satisfaction',
    'OLP-0202|repair structure satisfaction, P-prime atom syntax, and sentence scope',
    'OLP-0205|repair symbol-language statement, renaming target, Boolean disjunction, and negated satisfaction',
    'OLP-0206|repair tuple notation, outer-structure names, starred domains, abstract/FOL sentence distinction, and negated satisfaction',
    'OLP-0207|repair finite representatives, elementary equivalence, satisfaction subscripts, outer-structure names, negated satisfaction, and normal-logic hypothesis',
    'OLP-0211|repair primitive-recursion direction',
    'OLP-0212|repair composition x_n and projection arity k-to-n',
    'OLP-0213|make S_i stages cumulative',
    'OLP-0216|repair constant-function subscript const_2',
    'OLP-0217|repair less-than-or-equal label',
    'OLP-0218|repair bounded-minimization x/y binder',
    'OLP-0219|repair division/remainder direction, positive-divisor scope, and Euclid base cases',
    'OLP-0220|define sequence bound separately at k=0 and avoid p_-1',
    'OLP-0221|repair traversal index, g/g_f identifier, empty base case, and cumulative levels',
    'OLP-0225|qualify normal-form theorem to unary partial-recursive functions',
    'OLP-0226|remove impossible invalid-index branch; repair diagonal contradiction and opening partial-function scope',
    'OLP-0232|repair x-to-e substitutions twice and adjacent typo',
    'OLP-0233|repair universal partial-function scope',
    'OLP-0234|repair total/universal-function distinction',
    'OLP-0235|repair h-to-g identifier and Indonesian decision wording',
    'OLP-0236|repair Russell diagonal membership from X-notin-S to S-notin-S',
    'OLP-0239|repair partial equality and free proof variable; add post-iftag par for rendered a.Kita spacing',
    'OLP-0242|repair d/e indices',
    'OLP-0243|repair tuple order in reduction',
    'OLP-0245|repair completeness-reduction direction',
    'OLP-0247,OLP-0248,OLP-0249,OLP-0251|replace partial-function equalities by simeq where definedness is not guaranteed',
    'OLP-0250|repair theorem/proof scope to partial f with f(e) defined'
)

$retractions = @(
    'OLP-0191..OLP-0207|command-count, priming, models-versus-Entails, and renamed-structure deltas are admitted repairs, not drift',
    'OLP-0208..OLP-0251|composition macro direction is correct',
    'OLP-0208..OLP-0251|characteristic-function complement identity is valid',
    'OLP-0208..OLP-0251|K less-than-or-equal-m K_0 exercise is valid',
    'OLP-0208..OLP-0251|ordinary equality remains valid for total functions and extensional equality',
    'OLP-0208..OLP-0251|reader-facing program and string English terms are intentional technical vocabulary'
)

$preservedRisks = @(
    'OLP-0192|n,m inputs on the string domain are formally type-ambiguous without the exponent-length identification',
    'OLP-0195|source and target retain stale Section metadata non-standard-models',
    'OLP-0196|source and target retain stale Part metadata first-order-logic',
    'OLP-0220|strict less-than sequenceBound remains after prose says at most the bound',
    'OLP-0224|diagonalization rhetoric omits the effective-enumeration and universal-evaluation qualification'
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
    source_references=0L; target_references=0L; target_references_raw=0L
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
            if ($depth -ne 0) { throw "Unbalanced \$Command argument in: $Text" }
            continue
        }
        [void]$builder.Append($Text[$i]); $i++
    }
    return $builder.ToString()
}
function Normalize-Math([string]$Text) {
    return [regex]::Replace($Text,'[\s~]+','')
}
function Mask-ProseArguments([string]$Text) {
    $result=$Text
    foreach ($command in @('text','textrm','intertext','emph')) { $result=Replace-ProseArgument $result $command }
    return $result
}
function Get-MathSegments([string]$Text) {
    $Text=Mask-ProseArguments $Text
    $items=[Collections.Generic.List[object]]::new()
    foreach ($match in [regex]::Matches($Text,'(?<!\\)\$(.*?)(?<!\\)\$','Singleline')) {
        $items.Add([pscustomobject]@{ Index=$match.Index; Value=('INLINE:'+(Normalize-Math $match.Groups[1].Value)) })
    }
    foreach ($match in [regex]::Matches($Text,'\\\[(.*?)\\\]','Singleline')) {
        $items.Add([pscustomobject]@{ Index=$match.Index; Value=('DISPLAY:'+(Normalize-Math $match.Groups[1].Value)) })
    }
    return @($items | Sort-Object Index | ForEach-Object { $_.Value })
}
function Get-MathEnvironments([string]$Text) {
    $Text=Mask-ProseArguments $Text
    $items=[Collections.Generic.List[object]]::new()
    foreach ($environment in @('align','align*','multline','multline*','equation','equation*','aligned','cases','gather','gather*')) {
        $escaped=[regex]::Escape($environment)
        foreach ($match in [regex]::Matches($Text,"\\begin\{$escaped\}(?:\[[^\]]*\])?(?<body>.*?)\\end\{$escaped\}",'Singleline')) {
            $items.Add([pscustomobject]@{ Index=$match.Index; Value=($environment+':'+(Normalize-Math $match.Groups['body'].Value)) })
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
Assert-Exact ($targetBindings.Count -eq 61) 'bindings/count'

$manifest = Import-Csv -LiteralPath $manifestPath
$batch = @($manifest | Where-Object { [int]$_.stable_order -ge 191 -and [int]$_.stable_order -le 251 } | Sort-Object { [int]$_.stable_order })
Assert-Exact ($batch.Count -eq 61) 'manifest/batch-count'

$expectedIds = @(191..251 | ForEach-Object { 'OLP-{0:D4}' -f $_ })
Assert-Sequence 'manifest/ordered-ids' $expectedIds @($batch.closure_id)
Assert-Sequence 'bindings/ordered-ids' $expectedIds @($targetBindings.Id)

$manifestRecords = @($batch | ForEach-Object { "$($_.closure_id)|$($_.stable_order)|$($_.source_commit)|$($_.source_path)|$($_.source_sha256.ToLowerInvariant())|$($_.target_path)" })
$manifestBindingDigest = Get-TextDigest $manifestRecords
if ($expectedManifestBindingDigest -ceq '__CALIBRATE__') { "CALIBRATE manifest=$manifestBindingDigest" } else { Assert-Exact ($manifestBindingDigest -ceq $expectedManifestBindingDigest) 'manifest/binding-digest' }

$literalPatterns = [ordered]@{
    environments='(?<value>\\(?:begin|end)\{[^{}]+\})'
    labels='(?<value>\\ollabel\{[^{}]+\})'
    references='(?<value>\\(?:olref|Olref)(?:\[[^\]]*\]){0,3}\{[^{}]+\}|\\(?:cref|Cref)\{[^{}]+\})'
    imports='(?<value>\\olimport\*?(?:\[[^\]]*\])?\{[^{}]+\})'
}
$structuralRecords=[Collections.Generic.List[string]]::new()
$bindingRecords=[Collections.Generic.List[string]]::new()

for ($i=0; $i -lt $batch.Count; $i++) {
    $row=$batch[$i]; $binding=$targetBindings[$i]; $id=$row.closure_id
    Assert-Exact ($row.source_commit -ceq $expectedCommit) "$id/commit-binding"
    Assert-Exact ($row.source_path -and $row.source_sha256 -and $row.target_path) "$id/manifest-fields"
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
    $totals.source_bytes += (Get-Item -LiteralPath $sourcePath).Length
    $totals.target_bytes += (Get-Item -LiteralPath $targetPath).Length
    Assert-Exact ((Get-BraceBalance $sourceRaw) -eq 0) "$id/source-braces"
    Assert-Exact ((Get-BraceBalance $targetRaw) -eq 0) "$id/target-braces"

    $source=Remove-TexComments $sourceRaw; $target=Remove-TexComments $targetRaw
    $sourceCommands=@(Get-Sequence $source '(?<value>\\[A-Za-z@]+|\\.)')
    $targetCommands=@(Get-Sequence $target '(?<value>\\[A-Za-z@]+|\\.)')
    Register-ScopedMismatch 'commands' $id $sourceCommands $targetCommands
    $totals.source_commands += $sourceCommands.Count; $totals.target_commands += $targetCommands.Count
    Add-StructuralRecord $structuralRecords $id 'commands' $sourceCommands $targetCommands

    foreach ($category in $literalPatterns.Keys) {
        $sourceSequence=@(Get-Sequence $source $literalPatterns[$category])
        $targetSequence=@(Get-Sequence $target $literalPatterns[$category])
        if ($category -ceq 'references') { $totals.target_references_raw += $targetSequence.Count }
        if ($category -ceq 'references' -and $id -ceq 'OLP-0194') {
            $repair='\olref[stm]{prop:thq-standard}'
            Assert-Exact ((@($targetSequence | Where-Object { $_ -ceq $repair })).Count -eq 1) "$id/reference-repair-present"
            $targetSequence=@($targetSequence | Where-Object { $_ -cne $repair })
        }
        Assert-Sequence "$id/$category" $sourceSequence $targetSequence
        $totals["source_$category"] += $sourceSequence.Count
        $totals["target_$category"] += $targetSequence.Count
        Add-StructuralRecord $structuralRecords $id $category $sourceSequence $targetSequence
    }

    $sourceTokens=@(Get-Sequence $source '!!(?:\^)?(?:a|A)?\{(?<value>[^{}]+)\}(?:s|d)?' | ForEach-Object { [regex]::Replace($_,'\s+',' ') })
    $targetTokens=@(Get-Sequence $target '!!(?:\^)?(?:a|A)?\{(?<value>[^{}]+)\}(?:s|d)?' | ForEach-Object { [regex]::Replace($_,'\s+',' ') })
    Register-ScopedMismatch 'semantic_tokens' $id $sourceTokens $targetTokens
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

foreach ($category in $expectedMismatch.Keys) {
    if ($expectedManifestBindingDigest -ceq '__CALIBRATE__') { "CALIBRATE mismatch_$category=$($actualMismatch[$category] -join ',')" }
    Assert-Sequence "scoped-mismatch/$category" @($expectedMismatch[$category]) @($actualMismatch[$category])
}

# Exact render repair: the explicit paragraph break must follow the tagged TM
# conditional, preventing the observed `a.Kita` collision in the rendered page.
$olp0239Path=Join-Path $repoRoot 'locale\id\content\computability\computability-theory\equiv-ce-defs.tex'
$olp0239=Normalize-Newlines ([IO.File]::ReadAllText($olp0239Path))
Assert-Exact (([regex]::Matches($olp0239,'\}\s*\\par\s*\n')).Count -eq 1) 'OLP-0239/render-par-repair'

# Repaired negated satisfaction must use two defined commands, not an
# undefined composite command.
$allTarget = @($batch | ForEach-Object { Normalize-Newlines ([IO.File]::ReadAllText((Join-Path $repoRoot ($_.target_path -replace '/','\')))) }) -join "`n"
Assert-Exact (-not [regex]::IsMatch($allTarget,'\\notmodels_L')) 'batch/no-notmodels-L-composite'
Assert-Exact (-not [regex]::IsMatch($allTarget,'\b(?:TODO|FIXME|XXX)\b')) 'batch/no-placeholder-markers'
Assert-Exact (-not [regex]::IsMatch([regex]::Replace((Remove-TexComments $allTarget),'!!(?:\^)?(?:a|A)?\{[^{}\r\n]+\}(?:s|d)?',''),'!!')) 'batch/semantic-token-forms'

$reviewRecords=@($auditFindings + $correctionClasses + $retractions + $preservedRisks)
$reviewDigest=Get-TextDigest $reviewRecords
$structuralDigest=Get-TextDigest @($structuralRecords)
$bindingDigest=Get-TextDigest @($bindingRecords)
if ($expectedTargetBindingDigest -ceq '__CALIBRATE__') { "CALIBRATE target_binding=$bindingDigest" } else { Assert-Exact ($bindingDigest -ceq $expectedTargetBindingDigest) 'batch/target-binding-digest' }
if ($expectedStructuralDigest -ceq '__CALIBRATE__') { "CALIBRATE structural=$structuralDigest" } else { Assert-Exact ($structuralDigest -ceq $expectedStructuralDigest) 'batch/structural-digest' }
if ($expectedReviewDigest -ceq '__CALIBRATE__') { "CALIBRATE review=$reviewDigest" } else { Assert-Exact ($reviewDigest -ceq $expectedReviewDigest) 'batch/review-digest' }

$expectedTotals=[ordered]@{
    source_bytes=223335; target_bytes=237011
    source_commands=6144; target_commands=6173
    source_environments=924; target_environments=924
    source_semantic_tokens=270; target_semantic_tokens=269
    source_ids=61; target_ids=61
    source_labels=47; target_labels=47
    source_references=89; target_references=89; target_references_raw=90
    source_imports=57; target_imports=57
    source_math_segments=3435; target_math_segments=3466
    source_math_environments=109; target_math_environments=109
}
$calibrating=($expectedManifestBindingDigest -ceq '__CALIBRATE__')
foreach ($key in $totals.Keys) {
    if ($calibrating) { "CALIBRATE total_$key=$($totals[$key])" }
    else { Assert-Exact ($totals[$key] -eq $expectedTotals[$key]) "batch/frozen-total-$key" "expected=$($expectedTotals[$key]) actual=$($totals[$key])" }
}
if ($calibrating) { throw 'CALIBRATION COMPLETE: freeze the emitted digests and totals before admission.' }

"TARGET_BINDING_DIGEST sha256=$bindingDigest files=$($batch.Count) bytes=$($totals.target_bytes)"
"SOURCE_BINDING_DIGEST sha256=$manifestBindingDigest files=$($batch.Count) bytes=$($totals.source_bytes) commit=$expectedCommit"
"STRUCTURAL_TOTALS commands=$($totals.source_commands)/$($totals.target_commands) environments=$($totals.source_environments)/$($totals.target_environments) tokens=$($totals.source_semantic_tokens)/$($totals.target_semantic_tokens) ids=$($totals.source_ids)/$($totals.target_ids) labels=$($totals.source_labels)/$($totals.target_labels) refs_raw=$($totals.source_references)/$($totals.target_references_raw) refs_normalized=$($totals.source_references)/$($totals.target_references) imports=$($totals.source_imports)/$($totals.target_imports) math=$($totals.source_math_segments)/$($totals.target_math_segments) math_env=$($totals.source_math_environments)/$($totals.target_math_environments)"
"REVIEW_TOTALS audit_passes=$($auditFindings.Count) correction_classes=$($correctionClasses.Count) retractions=$($retractions.Count) preserved_risks=$($preservedRisks.Count) review_sha256=$reviewDigest"
"OLP0191_0251_BATCH_REPLAY_OK files=$($batch.Count) checks=$checks closure=OLP-0191..OLP-0251"
