$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$localeRoot = $PSScriptRoot
$repoRoot = [IO.Path]::GetFullPath((Join-Path $localeRoot '..\..'))
$controlRoot = [IO.Path]::GetFullPath((Join-Path $repoRoot '..\_control'))
$manifestPath = Join-Path $controlRoot 'OPENLOGIC_CLOSURE_MANIFEST_20260812.csv'
$configPath = Join-Path $localeRoot 'open-logic-config.sty'
$targetRoot = Join-Path $localeRoot 'content\incompleteness'
$expectedCommit = '9620cc73f9c8e0ad003c514a5d3748f29611c4c0'
$expectedManifestDigest = '9300f264106a3c0041e733840fd8bdcdbccafb2198ce1be11016dfa71102265e'
$expectedTargetDigest = 'fbfd4280a2a4daf3082a163a5d81e3e7a025f754a5af728365383513b04e80dc'
$expectedStructuralDigest = '524f5811544c88ae018931efb1ceaa9858893466ef04eb008cb4db763a802e08'
$expectedCorrectionDigest = '149dd7d2344068144f16636dab3b3933abfc0c96c608dc2247124decf8ff9ff4'

$targetBindings = @'
Id,TargetHash,TargetBytes
OLP-0274,9c70427f82138ab8a20aeb002c457471eefef64a7f9b644860c962f5d4e1576d,793
OLP-0275,13c1b74e981fc17f8eb4f5fd9a2bf12e01d43b01556fea3e759d6b02ed2ec6bb,317
OLP-0276,270111175eeaa48f2e7b26cdc2c929d1be7809ae354f3ce3155149d4a1156088,13183
OLP-0277,54408f9ba7d9e8b1715dda050651797eaf85e36541528fb7b5e9fe826f57ebb2,14949
OLP-0278,9252a5cc5bcf2826227f9f782451a177535ab6999b8a6d5f5b4f7d143cd4fe5c,5668
OLP-0279,6466a75fd23982401d8b3559c5312f80c3d61cec67d87555c9f5e83a10c325b1,6562
OLP-0280,300dba29e7240f4d1f202c89bb1d2d507bde930bcfc8fca405988fa4bf959fd4,595
OLP-0281,8783a1b8d2bf5574df3d7903a470463048d66e32ac475cb34d3d14e38af5e503,5422
OLP-0282,a62d1e5f913982da1ec15e833341424286c33a411fc1325d3dd49de3247c9230,4562
OLP-0283,c98fc780ba293c004dfe2ba465df6106027d0d35bacfcb8aee3ea5b316394063,5047
OLP-0284,7fa53f5f501b8e8b1f9d47c06d8629b356fdf68f92f4195f1a321941a36b492c,3210
OLP-0285,be5f4c64483c9246ab8a80ec33a612789375360ca323b268caed79ac000460d1,1606
OLP-0286,ab0b21d1108c5dcec5e5f165af1462b6c00582fcd3509705d86412ab0fa9fa2f,12201
OLP-0287,c4443d0b828d48219f5ab2b050cd1c5c7595e510578e1ac7bc0a27a912c53368,15159
OLP-0288,d173def38e6686f7c9309dd3a7cac832471a5e3b30f09cf2f0741ac11efaee5d,10144
OLP-0289,b8ae370a6c4dbac402d4f7f97de64aec226defefcd0eeb2598a382dbf46cf0d7,565
OLP-0290,7e0da54ea51c57fc7c6a97052e5daa9e2fb7919da22bf07281f04a504444c4a0,6867
OLP-0291,311a47be298c07aa01e1bb0d667dcde080d65573ef33724f6cf56eb3812e66f2,5545
OLP-0292,1b36f9f0dc6fc5e965ef0019d8c5fe4654fce8a9d0bb6a341bd70062915af96f,7571
OLP-0293,5aed8dde17c5c5ac6aa994d4482364831a85738a080efc062bd783a0b0992524,2368
OLP-0294,ccce84ebbb2db06ac35e55c3b5dba046be23a3e4ac03c85af6013eff60eaa03d,9209
OLP-0295,880a75a4a32158eb90719fbb1404c36fccad4ffdc2d088d40b1905b221669b4b,3726
OLP-0296,949198e0bda39ae2c44845e43203ee2dc1536fb84ae62e5537ae085686e93192,11136
OLP-0297,90cff0630fc33a29cb8c2429cc96e2a8d9571b4576534cb6a09f43eabc04b83b,3232
OLP-0298,efbdd4599b6efe4aada88b1406696e7593d8b0ec448fc6b481949047a1b5dbcd,2603
OLP-0299,6f2145d3a5828009a0396b3dbb83ec04830b66f227ee9e4f9ea206e7bee21c70,3194
OLP-0300,5bc0b89535103f9020b350d10b638405327d494570745e808daec14c6b91f181,12369
OLP-0301,97dbb97d69fbdd97eb066d2e5d00488a0e1f6814a010b780e918a5894e5d70a5,808
OLP-0302,bd7e595cf00481653dedda30bc0791fc260ebc090ff46487d4cf75f820a3518f,1793
OLP-0303,5bc66cd6946670a12859620c77200e1dc1b1140787845a59f2e8cf49cb2b0622,2130
OLP-0304,14fe2c98a577a57f5ad82ccf456cacdc491655610de3e0f1eeeed5d40084b44a,2133
OLP-0305,5582c75443a8f52b1edcf827769f3f6d01a6498cbb263b56f8f7c9857f739092,3254
OLP-0306,e322eac696c7ff0c90484011cae6537ea32743ceff89413dcc7cadb8bb239c39,1427
OLP-0307,f0346f7114cf793c2c6f1c33bad7725b07b6debf98503e513e92666caea883f8,1483
OLP-0308,dcc9a88c5d9efbe4749b967c339e5871a25a948e1b99c50e5c441dd0dba3de50,1798
OLP-0309,4b5cd9fd5c3baa61a9a295607d67cbd0a667c8863e12a933579152282ad1bbca,1596
OLP-0310,da316d56392fded7654946251d8173050c2ade9bf22868241de7e83a2961c8fd,2436
OLP-0311,d9648ce0c700f953ef14ce6a372001c65fa6bf5a8b734b8ec5c1eaec24536904,2956
OLP-0312,0e8fcb81647916a510d9bb02d8cba04c0240caa58f729b91c7449cdb9074afd6,488
OLP-0313,5ee4bf2828548098000010c88d198910a90bf6ce51d14f58c0b4063bf5b76bf8,4824
OLP-0314,138a5837409b73c8545bcb932a90d000e4d35a1b5ec9ad07734c9ff57c43afb9,6538
OLP-0315,d13ffb0823291f04ccbf42c0c1a09d02786b4cbfedcdf1375928f43f5b1fd64d,6185
OLP-0316,2fa0f2dae95fda59164dcd3534a44a32502361e61e32aa5c83a3c9e07cdbed86,7370
OLP-0317,3dfb35becd011ba9417a1d0f6a1ade5ecc05001f8540de524a4cf4247bae8c8e,1429
OLP-0318,164df19c5b1b4915a9f175652c9448bff2604108f2ef79290d61c397148f6325,3612
OLP-0319,4d2d848c35ad05da6cce5359993b6692482196532f648fd2348746413bccfe00,6058
OLP-0320,30f8892e9223af99c5e5874509bf8dd028ce38045c0bd68a4da8c8c8a281a7b3,7716
OLP-0321,1b8f86c97a3af6126ffa19611e46398a338059bb92a74bee070f17eefc9e4ea9,4871
'@ | ConvertFrom-Csv

$checks = 0
$utf8Strict = [Text.UTF8Encoding]::new($false, $true)
$totals = [ordered]@{
    source_bytes=0L; target_bytes=0L
    environment_tokens=0L; labels=0L; references=0L; citations=0L; imports=0L
    semantic_tokens=0L; math_segments=0L; math_environments=0L
    part_drivers=0L; chapter_drivers=0L; reader_units=0L
}

function Assert-Exact([bool]$Condition, [string]$Name, [string]$Detail='') {
    if (-not $Condition) { throw "FAIL $Name $Detail" }
    $script:checks++
}
function Get-Sha256([string]$Path) {
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}
function Get-BytesDigest([byte[]]$Bytes) {
    $sha=[Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash($Bytes))).Replace('-','').ToLowerInvariant() }
    finally { $sha.Dispose() }
}
function Get-TextDigest([object[]]$Items) {
    return Get-BytesDigest ([Text.Encoding]::UTF8.GetBytes((@($Items) -join "`n")))
}
function Normalize-Newlines([string]$Text) {
    return ($Text -replace "`r`n", "`n" -replace "`r", "`n")
}
function Read-StrictUtf8([string]$Path, [string]$Name) {
    $bytes=[IO.File]::ReadAllBytes($Path)
    try { $text=$script:utf8Strict.GetString($bytes) }
    catch { throw "FAIL $Name/utf8 $($_.Exception.Message)" }
    Assert-Exact (-not $text.Contains([char]0xFFFD)) "$Name/no-replacement-character"
    Assert-Exact (-not [regex]::IsMatch($text, '[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]')) "$Name/no-control-characters"
    return Normalize-Newlines $text
}
function Remove-TexComments([string]$Text) {
    $builder=[Text.StringBuilder]::new()
    foreach ($line in ((Normalize-Newlines $Text) -split "`n", 0, 'SimpleMatch')) {
        $cut=-1
        for ($i=0; $i -lt $line.Length; $i++) {
            if ($line[$i] -ne '%') { continue }
            $slashes=0
            for ($j=$i-1; $j -ge 0 -and $line[$j] -eq '\'; $j--) { $slashes++ }
            if (($slashes % 2) -eq 0) { $cut=$i; break }
        }
        if ($cut -ge 0) { [void]$builder.Append($line.Substring(0,$cut)) }
        else { [void]$builder.Append($line) }
        [void]$builder.Append("`n")
    }
    return $builder.ToString()
}
function Get-BraceBalance([string]$Text) {
    $balance=0; $comment=$false
    for ($i=0; $i -lt $Text.Length; $i++) {
        $c=$Text[$i]
        if ($comment) { if ($c -eq "`n") { $comment=$false }; continue }
        $slashes=0
        for ($j=$i-1; $j -ge 0 -and $Text[$j] -eq '\'; $j--) { $slashes++ }
        $escaped=(($slashes % 2) -eq 1)
        if ($c -eq '%' -and -not $escaped) { $comment=$true; continue }
        if ($escaped) { continue }
        if ($c -eq '{') { $balance++ }
        elseif ($c -eq '}') { $balance-- }
        if ($balance -lt 0) { return $balance }
    }
    return $balance
}
function Get-Sequence([string]$Text, [string]$Pattern, [string]$Group='value') {
    return @([regex]::Matches($Text, $Pattern, 'Singleline') | ForEach-Object { $_.Groups[$Group].Value })
}
function Test-Sequence([object[]]$Expected, [object[]]$Actual) {
    if ($Expected.Count -ne $Actual.Count) { return $false }
    for ($i=0; $i -lt $Expected.Count; $i++) {
        if ([string]$Expected[$i] -cne [string]$Actual[$i]) { return $false }
    }
    return $true
}
function Assert-Sequence([string]$Name, [object[]]$Expected, [object[]]$Actual) {
    Assert-Exact (Test-Sequence $Expected $Actual) $Name "source=$($Expected.Count) target=$($Actual.Count)"
}
function Assert-EnvironmentStack([string]$Id, [string]$Side, [object[]]$Tokens) {
    $stack=[Collections.Generic.List[string]]::new()
    foreach ($token in $Tokens) {
        $m=[regex]::Match($token, '^\\(?<kind>begin|end)\{(?<name>[^{}]+)\}$')
        Assert-Exact $m.Success "$Id/$Side/environment-token" $token
        if ($m.Groups['kind'].Value -eq 'begin') { $stack.Add($m.Groups['name'].Value); continue }
        Assert-Exact ($stack.Count -gt 0) "$Id/$Side/environment-underflow" $token
        $top=$stack[$stack.Count-1]
        Assert-Exact ($top -ceq $m.Groups['name'].Value) "$Id/$Side/environment-order" "expected=$top actual=$($m.Groups['name'].Value)"
        $stack.RemoveAt($stack.Count-1)
    }
    Assert-Exact ($stack.Count -eq 0) "$Id/$Side/environment-closure"
}
function Replace-ProseArgument([string]$Text, [string]$Command) {
    $needle="\$Command{"; $builder=[Text.StringBuilder]::new(); $i=0
    while ($i -lt $Text.Length) {
        if (($i+$needle.Length -le $Text.Length) -and ($Text.Substring($i,$needle.Length) -ceq $needle)) {
            [void]$builder.Append("\$Command{<TEXT>}"); $i += $needle.Length; $depth=1
            while ($i -lt $Text.Length -and $depth -gt 0) {
                if ($Text[$i] -eq '\' -and $i+1 -lt $Text.Length) { $i += 2; continue }
                if ($Text[$i] -eq '{') { $depth++ }
                elseif ($Text[$i] -eq '}') { $depth-- }
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
    foreach ($command in @('text','textrm','intertext','emph','mbox')) { $result=Replace-ProseArgument $result $command }
    return $result
}
function Normalize-Math([string]$Text) {
    return [regex]::Replace($Text, '[\s~]+', '')
}
function Get-MathSegments([string]$Text) {
    $Text=Mask-ProseArguments $Text
    $items=[Collections.Generic.List[object]]::new()
    foreach ($m in [regex]::Matches($Text, '(?<!\\)\$(.*?)(?<!\\)\$', 'Singleline')) {
        $items.Add([pscustomobject]@{Index=$m.Index;Value=('I:'+(Normalize-Math $m.Groups[1].Value))})
    }
    foreach ($m in [regex]::Matches($Text, '(?<!\\)\\\[(.*?)(?<!\\)\\\]', 'Singleline')) {
        $items.Add([pscustomobject]@{Index=$m.Index;Value=('D:'+(Normalize-Math $m.Groups[1].Value))})
    }
    return @($items | Sort-Object Index | ForEach-Object { $_.Value })
}
function Get-MathEnvironments([string]$Text) {
    $Text=Mask-ProseArguments $Text
    $items=[Collections.Generic.List[object]]::new()
    foreach ($environment in @('align','align*','multline','multline*','equation','equation*','aligned','cases','gather','gather*')) {
        $escaped=[regex]::Escape($environment)
        foreach ($m in [regex]::Matches($Text, "\\begin\{$escaped\}(?:\[[^\]]*\])?(?<body>.*?)\\end\{$escaped\}", 'Singleline')) {
            $items.Add([pscustomobject]@{Index=$m.Index;Value=($environment+':'+(Normalize-Math $m.Groups['body'].Value))})
        }
    }
    return @($items | Sort-Object Index | ForEach-Object { $_.Value })
}
function New-Edit([int]$Index, [string[]]$Old, [string[]]$New, [string]$Reason) {
    return [pscustomobject]@{Index=$Index;Old=$Old;New=$New;Reason=$Reason}
}
function Apply-ScopedEdits([string]$Id, [string]$Category, [object[]]$Items, [hashtable]$Map, [Collections.Generic.List[string]]$CorrectionRecords) {
    $list=[Collections.Generic.List[string]]::new()
    foreach ($item in $Items) { $list.Add([string]$item) }
    if (-not $Map.ContainsKey($Id)) { return @($list) }
    foreach ($edit in @($Map[$Id] | Sort-Object Index -Descending)) {
        Assert-Exact ($edit.Index -ge 0 -and $edit.Index+$edit.Old.Count -le $list.Count) "$Id/$Category/correction-range"
        $actualOld=@()
        if ($edit.Old.Count -gt 0) { $actualOld=@($list.GetRange($edit.Index,$edit.Old.Count)) }
        Assert-Sequence "$Id/$Category/correction-old" @($edit.Old) $actualOld
        if ($edit.Old.Count -gt 0) { $list.RemoveRange($edit.Index,$edit.Old.Count) }
        if ($edit.New.Count -gt 0) { $list.InsertRange($edit.Index,[string[]]$edit.New) }
        $CorrectionRecords.Add("$Id|$Category|$($edit.Index)|$(Get-TextDigest @($edit.Old))|$(Get-TextDigest @($edit.New))|$($edit.Reason)")
    }
    return @($list)
}

# These transformations apply only to the frozen English source skeleton. Each
# entry is bound to one closure path/ID and converts a known upstream defect or
# omission into the exact admitted Indonesian mathematical skeleton.
$mathEdits=@{
    'OLP-0277'=@(New-Edit 206 @() @('I:\Gamma') 'restore the theory symbol in the relation-representability clause')
    'OLP-0278'=@(
        New-Edit 35 @('I:\Gamma\Proves\Prov[\Gamma](\num{n})') @('I:\Gamma\Proves\OProv[\Gamma](\num{n})') 'use the object-language provability predicate'
        New-Edit 40 @('I:\lnot\Prov[\Gamma](\num{n})') @('I:\lnot\OProv[\Gamma](\num{n})') 'use the object-language provability predicate'
    )
    'OLP-0279'=@(
        New-Edit 15 @('I:!A(\num{n})') @('I:!A_n(\num{n})') 'restore the indexed formula family'
        New-Edit 18 @('I:\lnot!A(\num{n})\in\Gamma') @('I:\lnot!A_n(\num{n})\in\Gamma') 'restore the indexed formula family'
        New-Edit 59 @() @('I:!A') 'supply the previously unbound sentence subject'
    )
    'OLP-0284'=@(
        New-Edit 10 @() @('I:\len{z}=n') 'restore the sequence-length condition'
        New-Edit 26 @('I:\tuple{s_0,\dots,s_{k-1}}') @() 'move the tuple to its complete bounded definition'
        New-Edit 29 @() @('I:k\le\len{x}','I:\tuple{s_0,\dots,s_{k-1}}','I:p_{k-1}^{k(x+1)}') 'restore the arity bound, tuple, and exponent condition'
    )
    'OLP-0286'=@(
        New-Edit 36 @('D:\tuple{1,\tuple{1,\tuple{0,\Gn{!A\Sequent!A)}},\Gn{!A\land!B\Sequent!A},9},\Gn{\Sequent(!A\land!B)\lif!A},14}.') @('D:\tuple{1,\tuple{1,\tuple{0,\Gn{!A\Sequent!A}},\Gn{!A\land!B\Sequent!A},9},\Gn{\Sequent(!A\land!B)\lif!A},14}.') 'repair the malformed Goedel-code brace'
        New-Edit 38 @('I:\fn{EndSeq}(p)=(p)_{(p)_0+1}') @('I:\fn{EndSequent}(p)=(p)_{(p)_0+1}') 'use the declared EndSequent identifier'
        New-Edit 121 @('I:d') @('I:p') 'bind the derivation-code variable used by the definition'
        New-Edit 134 @('I:\fn{Deriv}(d)','D:\bforall{i<\len{\fn{SubtreeSeq}(p)}}{\fn{Correct}((\fn{SubtreeSeq}(p))_i}.') @('I:\fn{Deriv}(p)','D:\bforall{i<\len{\fn{SubtreeSeq}(p)}}{\fn{Correct}((\fn{SubtreeSeq}(p))_i)}.') 'bind p and close the bounded-universal formula'
        New-Edit 163 @('I:\len{(\fn{EndSequent}(x))_1}=1\land((\fn{EndSequent}(x))_1)_0=x') @('I:\len{(\fn{EndSequent}(x))_1}=1\land((\fn{EndSequent}(x))_1)_0=y') 'restore the represented conclusion variable'
    )
    'OLP-0287'=@(
        New-Edit 160 @() @('I:n=0','I:n\neq0') 'make the open-assumption label cases explicit'
        New-Edit 170 @("I:\bexists{j<(d')_0}{d=(d')_j}") @("I:\bexists{j<(d')_0}{d=(d')_{j+1}}") 'correct child indexing in the subderivation relation'
    )
    'OLP-0288'=@(New-Edit 76 @('I:a') @('I:c') 'bind the constant-code variable used in the quantified rule')
    'OLP-0291'=@(
        New-Edit 5 @('I:!A(x_0,\dots,x_k,y)') @('I:!A_f(x_0,\dots,x_k,y)') 'restore the representing formula subscript'
        New-Edit 11 @() @('I:\Th{Q}') 'state the theory in which the derivation is carried out'
        New-Edit 47 @('I:A_f(\num{n_0},\dots,\num{n_k},(s)_1)') @('I:A_f(\num{n_0},\dots,\num{n_k},\num{(s)_1})') 'restore numeral quotation of the coded output'
    )
    'OLP-0293'=@(
        New-Edit 2 @('I:h(x,\vecz)') @('I:h(\vecx,y)') 'align the primitive-recursion arguments'
        New-Edit 31 @('D:\hath(\vecx,y)=\umin{d}{(\beta(d,0)=f(\vecx)\land\bforall{i<y}{\beta(d,i+1)=g(\vecx,i,\beta(d,i)})}.') @('D:\hath(\vecx,y)=\umin{d}{(\beta(d,0)=f(\vecx)\land\bforall{i<y}{\beta(d,i+1)=g(\vecx,i,\beta(d,i))})}.') 'close the minimization predicate parenthesis'
    )
    'OLP-0294'=@(
        New-Edit 28 @('D:\Char{=}(x_0,x_1)=\begin{cases}1&\text{<TEXT>}x_0=x_1\\0&otherwise\end{cases}') @('D:\Char{=}(x_0,x_1)=\begin{cases}1&\text{<TEXT>}x_0=x_1\\0&\text{<TEXT>}\end{cases}') 'place the second cases label in text mode'
        New-Edit 38 @('I:Q\Proves\eq/[\numn][\numm]') @('I:\Th{Q}\Proves\eq/[\numn][\numm]') 'use the declared theory macro'
    )
    'OLP-0296'=@(New-Edit 152 @("I:c'") @('I:c') 'use the witness variable established in the proof')
    'OLP-0300'=@(
        New-Edit 75 @('I:\Th{Q}\Proves\eq[t_2][\numn]') @('I:\Th{Q}\Proves\eq[t_2][\numm]') 'restore the second term value'
        New-Edit 91 @("I:\Th{Q}\Proves\eq[\numn+{\numk}'][\numm]") @("I:\Th{Q}\Proves\eq[{\numk}'+\numn][\numm]") 'align the addition case with Q axiom 4'
        New-Edit 110 @("I:\eq/[z'][\Obj0]",'I:!Q_3') @("I:\eq[z'][\Obj0]",'I:!Q_2') 'repair equality syntax and the zero-successor axiom number'
        New-Edit 115 @('I:!Q_3') @('I:!Q_2') 'cite the zero-successor axiom consistently'
        New-Edit 195 @('I:\lnot\bexists{x<t}!A(x)') @('I:\lnot\bexists{x<t}{!A(x)}') 'scope the bounded existential body'
        New-Edit 219 @('I:\lexists{x}!A(x)') @('I:\lexists[x][!A(x)]') 'use the declared existential macro syntax'
    )
    'OLP-0318'=@(New-Edit 17 @('I:\lexists[x][\Prf[\Th{PA}](x,y)]') @('I:\lexists[x][\OPrf[\Th{PA}](x,y)]') 'use the object-language proof predicate')
    'OLP-0319'=@(
        New-Edit 19 @('I:\lnot\Prov[\Th{PA}](\gn{!G_\Th{PA}})') @('I:\lnot\OProv[\Th{PA}](\gn{!G_\Th{PA}})') 'use the object-language provability predicate'
        New-Edit 41 @('I:!A\ident\OProv(\gn{G})') @('I:!A\ident\OProv(\gn{!G})') 'quote the object-language fixed point'
        New-Edit 48 @('I:\OCon[T]') @('I:\OCon[\Th{T}]') 'use the declared theory macro in consistency notation'
    )
    'OLP-0321'=@(New-Edit 20 @('I:f(x)=U(\umin{s}{T(e,x,s)})') @('I:f(x)\simeqU(\umin{s}{T(e,x,s)})') 'state the partial-function equality')
}

$mathEnvironmentEdits=@{
    'OLP-0284'=@(New-Edit 0 @('multline*:\bforall{i<\len{x}}{\bforall{z<x}{}}\\(\bexists{j<z}{z=\Gn{\Objv_j}}\lif\lnot\fn{FreeOcc}(x,z,i)).') @('multline*:\fn{Frm}(x)\land{}\\\bforall{i<\len{x}}{\bforall{z<x}{}}\\(\bexists{j<z}{z=\Gn{\Objv_j}}\lif\lnot\fn{FreeOcc}(x,z,i)).') 'restore the formula-code conjunct')
    'OLP-0286'=@(New-Edit 4 @('multline*:\fn{Sequent}(\fn{EndSequent}(p))\land{}\\[(\fn{LastRule}(p)=1\land\fn{FollowsBy}_{\LeftR\Weakening}(p))\lor\dots\lor{}\\(\fn{LastRule}(p)=20\land\fn{FollowsBy}_{\eq}(p))\lor{}\\(p)_0=0\land\fn{InitialSeq}(\fn{EndSequent}(p))]') @('multline*:\fn{Sequent}(\fn{EndSequent}(p))\land{}\\[(\fn{LastRule}(p)=1\land\fn{FollowsBy}_{\LeftR\Weakening}(p))\lor\dots\lor{}\\(\fn{LastRule}(p)=20\land\fn{FollowsBy}_{\eq}(p))\lor{}\\(p)_0=0\land\fn{InitSeq}(\fn{EndSequent}(p))]') 'use the declared InitSeq identifier')
    'OLP-0287'=@(New-Edit 5 @(
        'multline*:\fn{Sent}(\fn{EndFmla}(d))\land{}\\(\fn{LastRule}(d)=1\land\fn{FollowsBy}_{\Intro\land}(d))\lor\dots\lor{}\\(\fn{LastRule}(d)=16\land\fn{FollowsBy}_{\Elim\eq}(d))\lor{}\\\bexists{n<d}{\bexists{x<d}{(d=\tuple{0,x,n})}}.',
        'multline*:\bexists{s<\fn{SubtreeSeq}(d)}{(\fn{Subseq}(s,\fn{SubtreeSeq}(d))\land(s)_0=d\land{}}\\\bexists{n<d}{((s)_{\len{s}\tsub1}=\tuple{0,z,n}\land{}}\\\bforall{i<(\len{s}\tsub1)}{(\fn{Subderiv}((s)_{i+1},(s)_i)\land{}}\\\fn{DischargeLabel}((s)_i)\neqn))).'
    ) @(
        'multline*:\fn{Sent}(\fn{EndFmla}(d))\land{}\\[(\fn{LastRule}(d)=1\land\fn{FollowsBy}_{\Intro\land}(d))\lor\dots\lor{}\\(\fn{LastRule}(d)=16\land\fn{FollowsBy}_{\Elim\eq}(d))\lor{}\\\bexists{n<d}{\bexists{x<d}{(d=\tuple{0,x,n})}}].',
        'multline*:\bexists{s\leq\fn{SubtreeSeq}(d)}{\fn{Subseq}(s,\fn{SubtreeSeq}(d))\land(s)_0=d\land{}\\\Bigl[(s)_{\len{s}\tsub1}=\tuple{0,z,0}\lor{}\\\bexists{n<d}{n\neq0\land(s)_{\len{s}\tsub1}=\tuple{0,z,n}\land{}\\\bforall{i<(\len{s}\tsub1)}{\bigl(\fn{Subderiv}((s)_{i+1},(s)_i)\land\fn{DischargeLabel}((s)_i)\neqn\bigr)}}\Bigr]}.'
    ) 'restore grouping, bounded sequence, open-label zero case, and child predicate')
    'OLP-0288'=@(New-Edit 3 @(
        'multline*:\fn{QR}_1(d,i)\defiff\bexists{b<(d)_i}{\bexists{x<(d)_i}{\bexists{a<(d)_i}{\bexists{c<(d)_j}{(}}}}\\\fn{Var}(x)\land\fn{Const}(c)\land{}\\(d)_i=\Gn{(}\concatb\concat\Gn{\lif}\concat\Gn{\lforall}\concatx\concata\concat\Gn{)}\land{}\\(d)_j=\Gn{(}\concatb\concat\Gn{\lif}\concat\fn{Subst}(a,c,x)\concat\Gn{)}\land{}\\\fn{Sent}(b)\land\fn{Sent}(\fn{Subst}(a,c,x))\land{}\bforall{k<\len{b}}{(b)_k\neq(c)_0})',
        'align*:\fn{hCond}(s,y,0)&=y\\\fn{hCond}(s,y,n+1)&=\Gn{(}\concat(s)_{n}\concat\Gn{\lif}\concat\fn{Cond}(s,y,n)\concat\Gn{)}\\\fn{Cond}(s,y)&=\fn{hCond}(s,y,\len{s})\\\intertext{<TEXT>}\Prf[\Gamma](x,y)&\defiff\bexists{s<\fn{sequenceBound}(x,x)}{(}\\&\qquad(x)_{\len{x}-1}=\fn{Cond}(s,y)\land{}\\&\qquad\bforall{i<\len{s}}{(s)_i\in\Gamma}\land{}\\&\qquad\fn{Deriv}(x)).'
    ) @(
        'multline*:\fn{QR}_1(d,i)\defiff\bexists{j<i}{\bexists{b<(d)_i}{\bexists{x<(d)_i}{\bexists{a<(d)_i}{\bexists{c<(d)_j}{(}}}}}\\\fn{Var}(x)\land\fn{Const}(c)\land{}\\(d)_i=\Gn{(}\concatb\concat\Gn{\lif}\concat\Gn{\lforall}\concatx\concata\concat\Gn{)}\land{}\\(d)_j=\Gn{(}\concatb\concat\Gn{\lif}\concat\fn{Subst}(a,c,x)\concat\Gn{)}\land{}\\\fn{Sent}(b)\land\fn{Sent}(\fn{Subst}(a,c,x))\land{}\bforall{k<\len{b}}{(b)_k\neq(c)_0}).',
        'align*:\fn{hCond}(s,y,0)&=y\\\fn{hCond}(s,y,n+1)&=\Gn{(}\concat(s)_{n}\concat\Gn{\lif}\concat\fn{hCond}(s,y,n)\concat\Gn{)}\\\fn{Cond}(s,y)&=\fn{hCond}(s,y,\len{s})\\\intertext{<TEXT>}\Prf[\Gamma](x,y)&\defiff\bexists{s<\fn{sequenceBound}(x,x)}{(}\\&\qquad(x)_{\len{x}-1}=\fn{Cond}(s,y)\land{}\\&\qquad\bforall{i<\len{s}}{R_\Gamma((s)_i)}\land{}\\&\qquad\fn{Deriv}(x)).'
    ) 'bind the QR index and repair conditional recursion and theory-membership predicate')
    'OLP-0294'=@(New-Edit 1 @('cases:1&\text{<TEXT>}x_0=x_1\\0&otherwise') @('cases:1&\text{<TEXT>}x_0=x_1\\0&\text{<TEXT>}') 'place the second cases label in text mode')
    'OLP-0296'=@(New-Edit 1 @("align:\Th{Q}&\Proves\eq[(a'+\numn')][(a'+\numn)']\quad\text{<TEXT>}\ollabel{step5}\\\Th{Q}&\Proves\eq[(a'+\numn')][(a+\numn')']\quad\text{<TEXT>}\ollabel{step6}\\\Th{Q}&\Proves\eq[(a'+\numn)'][(a+\numn')']\quad\text{<TEXT>}\notag") @("align:\Th{Q}&\Proves\eq[(a'+\numn')][(a'+\numn)']\quad\text{<TEXT>}\ollabel{step5}\\\Th{Q}&\Proves\eq[(a'+\numn)'][(a+\numn)'']\quad\text{<TEXT>}\ollabel{step6}\\\Th{Q}&\Proves\eq[(a+\numn')'][(a+\numn)'']\quad\text{<TEXT>}\ollabel{step7}\\\Th{Q}&\Proves\eq[(a'+\numn')][(a+\numn')']\quad\text{<TEXT>}\notag") 'restore the missing two-step equality chain')
}

$labelEdits=@{
    'OLP-0296'=@(New-Edit 6 @() @('\ollabel{step7}') 'label the restored equality step')
    'OLP-0315'=@(New-Edit 2 @('\ollabel{thm:oconsis-q}') @('\ollabel{def:omega-consistency-inp}') 'remove the duplicate theorem label from the omega-consistency definition')
}
$referenceEdits=@{
    'OLP-0295'=@(New-Edit 0 @('\olref[inc][req][cmp]{prop:rep2}') @('\olref[inc][req][cmp]{prop:rep1}') 'cite the applicable closure proposition')
    'OLP-0296'=@(New-Edit 5 @() @('\olref{step7}') 'cite the restored equality step')
    'OLP-0320'=@(New-Edit 14 @('\olref{L-8}') @('\olref{L-9}') 'cite the reflection line actually used')
}

Assert-Exact (Test-Path -LiteralPath $manifestPath) 'manifest/present'
Assert-Exact (Test-Path -LiteralPath $configPath) 'config/present'
Assert-Exact (Test-Path -LiteralPath $targetRoot) 'target-root/present'
Assert-Exact ($targetBindings.Count -eq 48) 'bindings/count'

$manifest=Import-Csv -LiteralPath $manifestPath
$batch=@($manifest | Where-Object { [int]$_.stable_order -ge 274 -and [int]$_.stable_order -le 321 } | Sort-Object {[int]$_.stable_order})
$expectedIds=@(274..321 | ForEach-Object { 'OLP-{0:D4}' -f $_ })
Assert-Exact ($batch.Count -eq 48) 'manifest/batch-count'
Assert-Sequence 'manifest/ordered-ids' $expectedIds @($batch.closure_id)
Assert-Sequence 'bindings/ordered-ids' $expectedIds @($targetBindings.Id)
Assert-Exact ((@($batch | Where-Object { $_.source_path -notlike 'content/incompleteness/*' })).Count -eq 0) 'manifest/path-scope'

$manifestRecords=@($batch | ForEach-Object { "$($_.closure_id)|$($_.stable_order)|$($_.source_commit)|$($_.source_path)|$($_.source_sha256.ToLowerInvariant())|$($_.target_path)" })
$bindingRecords=[Collections.Generic.List[string]]::new()
$structuralRecords=[Collections.Generic.List[string]]::new()
$correctionRecords=[Collections.Generic.List[string]]::new()
$targetRelativeActual=@(Get-ChildItem -LiteralPath $targetRoot -Recurse -File -Filter '*.tex' | ForEach-Object {
    ([IO.Path]::GetRelativePath($repoRoot,$_.FullName) -replace '\\','/').ToLowerInvariant()
} | Sort-Object)
$targetRelativeExpected=@($batch.target_path | ForEach-Object { $_.ToLowerInvariant() } | Sort-Object)
Assert-Sequence 'target-tree/exact-tex-closure' $targetRelativeExpected $targetRelativeActual

$configText=Read-StrictUtf8 $configPath 'config'
$tokenBases=[Collections.Generic.List[string]]::new()
$environmentPattern='(?<value>\\(?:begin|end)\{[^{}]+\})'
$labelPattern='(?<value>\\ollabel\{[^{}]+\})'
$referencePattern='(?<value>\\(?:olref|Olref)(?:\[[^\]]*\]){0,3}\{[^{}]+\}|\\(?:cref|Cref)\{[^{}]+\})'
$citationPattern='(?<value>\\(?:cite|parencite|textcite)(?:\[[^\]]*\]){0,2}\{[^{}]+\})'
$importPattern='(?<value>\\olimport\*?(?:\[[^\]]*\])?\{[^{}]+\})'
$tokenPattern='(?<full>!!(?:\^)?(?:a|A)?\{(?<value>[^{}]+)\}(?:s|d)?)'

for ($i=0; $i -lt $batch.Count; $i++) {
    $row=$batch[$i]; $binding=$targetBindings[$i]; $id=$row.closure_id
    Assert-Exact ($row.source_commit -ceq $expectedCommit) "$id/source-commit"
    Assert-Exact ($row.target_path -ceq "locale/id/$($row.source_path)") "$id/target-path"
    $sourcePath=Join-Path $repoRoot ($row.source_path -replace '/','\')
    $targetPath=Join-Path $repoRoot ($row.target_path -replace '/','\')
    Assert-Exact (Test-Path -LiteralPath $sourcePath) "$id/source-present"
    Assert-Exact (Test-Path -LiteralPath $targetPath) "$id/target-present"
    Assert-Exact ((Get-Sha256 $sourcePath) -ceq $row.source_sha256.ToLowerInvariant()) "$id/source-hash"
    Assert-Exact ((Get-Sha256 $targetPath) -ceq $binding.TargetHash) "$id/target-hash"
    Assert-Exact ((Get-Item -LiteralPath $targetPath).Length -eq [int64]$binding.TargetBytes) "$id/target-bytes"
    $sourceRaw=Read-StrictUtf8 $sourcePath "$id/source"
    $targetRaw=Read-StrictUtf8 $targetPath "$id/target"
    $totals.source_bytes += (Get-Item -LiteralPath $sourcePath).Length
    $totals.target_bytes += (Get-Item -LiteralPath $targetPath).Length
    Assert-Exact ((Get-BraceBalance $sourceRaw) -eq 0) "$id/source-braces"
    Assert-Exact ((Get-BraceBalance $targetRaw) -eq 0) "$id/target-braces"
    $source=Remove-TexComments $sourceRaw
    $target=Remove-TexComments $targetRaw
    Assert-Exact (-not [regex]::IsMatch($target,'\b(?:TODO|FIXME|XXX)\b')) "$id/no-placeholders"

    $sourceEnvironments=@(Get-Sequence $source $environmentPattern)
    $targetEnvironments=@(Get-Sequence $target $environmentPattern)
    Assert-EnvironmentStack $id 'source' $sourceEnvironments
    Assert-EnvironmentStack $id 'target' $targetEnvironments
    Assert-Sequence "$id/environments" $sourceEnvironments $targetEnvironments
    $totals.environment_tokens += $targetEnvironments.Count

    $sourceLabels=@(Get-Sequence $source $labelPattern)
    $sourceLabelsNormalized=@(Apply-ScopedEdits $id 'labels' $sourceLabels $labelEdits $correctionRecords)
    $targetLabels=@(Get-Sequence $target $labelPattern)
    Assert-Sequence "$id/labels" $sourceLabelsNormalized $targetLabels
    $totals.labels += $targetLabels.Count

    $sourceReferences=@(Get-Sequence $source $referencePattern)
    $sourceReferencesNormalized=@(Apply-ScopedEdits $id 'references' $sourceReferences $referenceEdits $correctionRecords)
    $targetReferences=@(Get-Sequence $target $referencePattern)
    Assert-Sequence "$id/references" $sourceReferencesNormalized $targetReferences
    $totals.references += $targetReferences.Count

    $sourceCitations=@(Get-Sequence $source $citationPattern)
    $targetCitations=@(Get-Sequence $target $citationPattern)
    Assert-Sequence "$id/citations" $sourceCitations $targetCitations
    $totals.citations += $targetCitations.Count

    $sourceImports=@(Get-Sequence $source $importPattern)
    $targetImports=@(Get-Sequence $target $importPattern)
    Assert-Sequence "$id/imports" $sourceImports $targetImports
    $totals.imports += $targetImports.Count

    $sourceTokenMatches=@([regex]::Matches($source,$tokenPattern,'Singleline'))
    $targetTokenMatches=@([regex]::Matches($target,$tokenPattern,'Singleline'))
    $sourceTokenForms=@($sourceTokenMatches | ForEach-Object { [regex]::Replace($_.Groups['full'].Value,'\s+',' ') })
    $targetTokenForms=@($targetTokenMatches | ForEach-Object { [regex]::Replace($_.Groups['full'].Value,'\s+',' ') })
    Assert-Exact ($sourceTokenForms.Count -eq $targetTokenForms.Count) "$id/semantic-token-count"
    $sourceBases=@($sourceTokenMatches | ForEach-Object { [regex]::Replace($_.Groups['value'].Value,'\s+',' ') } | Sort-Object)
    $targetBases=@($targetTokenMatches | ForEach-Object { [regex]::Replace($_.Groups['value'].Value,'\s+',' ') } | Sort-Object)
    Assert-Sequence "$id/semantic-token-bases" $sourceBases $targetBases
    foreach ($base in $targetBases) { $tokenBases.Add($base) }
    $totals.semantic_tokens += $targetTokenForms.Count
    Assert-Exact (-not [regex]::IsMatch([regex]::Replace($target,$tokenPattern,''),'!!')) "$id/no-malformed-semantic-token"

    $sourceMath=@(Get-MathSegments $source)
    $sourceMathNormalized=@(Apply-ScopedEdits $id 'math' $sourceMath $mathEdits $correctionRecords)
    $targetMath=@(Get-MathSegments $target)
    Assert-Sequence "$id/math-skeleton" $sourceMathNormalized $targetMath
    $totals.math_segments += $targetMath.Count

    $sourceMathEnvironment=@(Get-MathEnvironments $source)
    $sourceMathEnvironmentNormalized=@(Apply-ScopedEdits $id 'math-environments' $sourceMathEnvironment $mathEnvironmentEdits $correctionRecords)
    $targetMathEnvironment=@(Get-MathEnvironments $target)
    Assert-Sequence "$id/math-environment-skeleton" $sourceMathEnvironmentNormalized $targetMathEnvironment
    $totals.math_environments += $targetMathEnvironment.Count

    if ($row.source_role -ceq 'reader_unit') {
        $sourceFileIds=@(Get-Sequence $source '\\olfileid\{(?<value>[^{}]+\}\{[^{}]+\}\{[^{}]+)\}')
        $targetFileIds=@(Get-Sequence $target '\\olfileid\[id\]\{(?<value>[^{}]+\}\{[^{}]+\}\{[^{}]+)\}')
        Assert-Exact ($sourceFileIds.Count -eq 1 -and $targetFileIds.Count -eq 1) "$id/olfileid/count"
        Assert-Sequence "$id/olfileid/identity" $sourceFileIds $targetFileIds
        Assert-Exact (-not [regex]::IsMatch($target,'\\olfileid\{')) "$id/olfileid/locale-marker"
        $totals.reader_units++
    }
    elseif ($row.source_role -ceq 'part_driver') {
        $sourcePart=@(Get-Sequence $source '\\olpart\{(?<value>[^{}]+)\}\{(?<title>[^{}]+)\}')
        $targetPart=@(Get-Sequence $target '\\olpart\{(?<value>[^{}]+)\}\{(?<title>[^{}]+)\}')
        Assert-Exact ($sourcePart.Count -eq 1 -and $targetPart.Count -eq 1) "$id/olpart/count"
        Assert-Sequence "$id/olpart/identity" $sourcePart $targetPart
        Assert-Exact (-not [regex]::IsMatch($target,'\\olpart\[id\]')) "$id/olpart/no-false-locale-option"
        $sourceTitle=[regex]::Match($source,'\\olpart\{[^{}]+\}\{(?<title>[^{}]+)\}').Groups['title'].Value
        $targetTitle=[regex]::Match($target,'\\olpart\{[^{}]+\}\{(?<title>[^{}]+)\}').Groups['title'].Value
        Assert-Exact ($targetTitle.Length -gt 0 -and $targetTitle -cne $sourceTitle) "$id/olpart/localized-title"
        $totals.part_drivers++
    }
    elseif ($row.source_role -ceq 'chapter_driver') {
        $sourceChapter=@(Get-Sequence $source '\\olchapter\{(?<value>[^{}]+\}\{[^{}]+)\}\{')
        $targetChapter=@(Get-Sequence $target '\\olchapter\{(?<value>[^{}]+\}\{[^{}]+)\}\{')
        Assert-Exact ($sourceChapter.Count -eq 1 -and $targetChapter.Count -eq 1) "$id/olchapter/count"
        Assert-Sequence "$id/olchapter/identity" $sourceChapter $targetChapter
        Assert-Exact (-not [regex]::IsMatch($target,'\\olchapter\[id\]')) "$id/olchapter/no-false-locale-option"
        $sourceTitle=[regex]::Match($source,'\\olchapter\{[^{}]+\}\{[^{}]+\}\{(?<title>[^{}]+(?:\{[^{}]*\}[^{}]*)*)\}').Groups['title'].Value
        $targetTitle=[regex]::Match($target,'\\olchapter\{[^{}]+\}\{[^{}]+\}\{(?<title>[^{}]+(?:\{[^{}]*\}[^{}]*)*)\}').Groups['title'].Value
        Assert-Exact ($targetTitle.Length -gt 0 -and $targetTitle -cne $sourceTitle) "$id/olchapter/localized-title"
        $totals.chapter_drivers++
    }
    else { throw "FAIL $id/unexpected-source-role $($row.source_role)" }

    $structuralRecords.Add("$id|env|$(Get-TextDigest $sourceEnvironments)|$(Get-TextDigest $targetEnvironments)")
    $structuralRecords.Add("$id|labels|$(Get-TextDigest $sourceLabelsNormalized)|$(Get-TextDigest $targetLabels)")
    $structuralRecords.Add("$id|refs|$(Get-TextDigest $sourceReferencesNormalized)|$(Get-TextDigest $targetReferences)")
    $structuralRecords.Add("$id|cites|$(Get-TextDigest $sourceCitations)|$(Get-TextDigest $targetCitations)")
    $structuralRecords.Add("$id|imports|$(Get-TextDigest $sourceImports)|$(Get-TextDigest $targetImports)")
    $structuralRecords.Add("$id|token-bases|$(Get-TextDigest $sourceBases)|$(Get-TextDigest $targetBases)")
    $structuralRecords.Add("$id|math|$(Get-TextDigest $sourceMathNormalized)|$(Get-TextDigest $targetMath)")
    $structuralRecords.Add("$id|mathenv|$(Get-TextDigest $sourceMathEnvironmentNormalized)|$(Get-TextDigest $targetMathEnvironment)")
    $bindingRecords.Add("$id|$($row.target_path)|$($binding.TargetHash)|$($binding.TargetBytes)")
}

Assert-Exact ($totals.part_drivers -eq 1) 'batch/part-driver-count'
Assert-Exact ($totals.chapter_drivers -eq 5) 'batch/chapter-driver-count'
Assert-Exact ($totals.reader_units -eq 42) 'batch/reader-unit-count'
foreach ($base in @($tokenBases | Sort-Object -Unique)) {
    Assert-Exact ([regex]::IsMatch($configText,'\\settexttoken(?:\[[^\]]*\])?\{'+[regex]::Escape($base)+'\}')) "token/localized/$base"
}

$manifestDigest=Get-TextDigest $manifestRecords
$targetDigest=Get-TextDigest @($bindingRecords)
$structuralDigest=Get-TextDigest @($structuralRecords)
$correctionDigest=Get-TextDigest @($correctionRecords | Sort-Object)
$calibrating=($expectedManifestDigest -ceq '__CALIBRATE__')
if ($calibrating) {
    "CALIBRATE manifest=$manifestDigest"
    "CALIBRATE target=$targetDigest"
    "CALIBRATE structural=$structuralDigest"
    "CALIBRATE corrections=$correctionDigest count=$($correctionRecords.Count)"
    foreach ($key in $totals.Keys) { "CALIBRATE total_$key=$($totals[$key])" }
    throw 'CALIBRATION COMPLETE: freeze the emitted digests.'
}
Assert-Exact ($manifestDigest -ceq $expectedManifestDigest) 'batch/manifest-digest'
Assert-Exact ($targetDigest -ceq $expectedTargetDigest) 'batch/target-digest'
Assert-Exact ($structuralDigest -ceq $expectedStructuralDigest) 'batch/structural-digest'
Assert-Exact ($correctionDigest -ceq $expectedCorrectionDigest) 'batch/correction-digest'

"SOURCE_BINDING_DIGEST sha256=$manifestDigest files=$($batch.Count) bytes=$($totals.source_bytes) commit=$expectedCommit"
"TARGET_BINDING_DIGEST sha256=$targetDigest files=$($batch.Count) bytes=$($totals.target_bytes)"
"STRUCTURAL_AGGREGATES env_tokens=$($totals.environment_tokens) labels=$($totals.labels) refs=$($totals.references) cites=$($totals.citations) imports=$($totals.imports) semantic_tokens=$($totals.semantic_tokens) math_segments=$($totals.math_segments) math_environments=$($totals.math_environments) part_drivers=$($totals.part_drivers) chapter_drivers=$($totals.chapter_drivers) reader_units=$($totals.reader_units)"
"CORRECTION_NORMALIZATION sha256=$correctionDigest scoped_edits=$($correctionRecords.Count)"
"INCOMPLETENESS_BATCH_REPLAY_OK files=$($batch.Count) checks=$checks closure=OLP-0274..OLP-0321 structural_sha256=$structuralDigest"
