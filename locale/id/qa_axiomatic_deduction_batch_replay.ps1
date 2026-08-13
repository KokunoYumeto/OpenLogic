$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$localeRoot = $PSScriptRoot
$repoRoot = [IO.Path]::GetFullPath((Join-Path $localeRoot '..\..'))
$controlRoot = [IO.Path]::GetFullPath((Join-Path $repoRoot '..\_control'))
$manifestPath = Join-Path $controlRoot 'OPENLOGIC_CLOSURE_MANIFEST_20260812.csv'
$expectedCommit = '9620cc73f9c8e0ad003c514a5d3748f29611c4c0'
$relativeDir = 'content/first-order-logic/axiomatic-deduction'

# SourceBlob is the Git object at $expectedCommit. SourceHash is the SHA-256
# over that object's raw bytes and must agree with the closure manifest.
# TargetHash freezes the independently reviewed final Indonesian bytes.
$units = @(
    [pscustomobject]@{ Id='OLP-0112'; Name='axiomatic-deduction.tex';             SourceBlob='daf6bdb930f3d83932f77b38e7a815773bd2f86a'; BlobHash='82b05cdab523aa9e7581b305adc4b065f01cb042bced407a85e776e0f3895382'; SourceHash='ba510c171a8d19895307b36b2b06d3f64970bc5d926cfad52412da2a0727db20'; TargetHash='f6b51089ffaa91997438e89c7f77d8c03842414183a1440c26d123fdc3acedc4' }
    [pscustomobject]@{ Id='OLP-0113'; Name='rules-and-proofs.tex';                SourceBlob='29cce9257ebb2a6bc649a00ceaaf0b40b8a47711'; BlobHash='8b5cf02fabe434821d3a74db8fa803d25c772e38254c391edf03186b3dc23257'; SourceHash='c630189af9db5f45a849e5d1b6362895bf575dd6d2236a169eb5e0fdba9ed439'; TargetHash='b7bf7c025b50ba0176e40eb26306e512423c367cda2dc7fa8c4c9fa33b4c4988' }
    [pscustomobject]@{ Id='OLP-0114'; Name='axioms-rules-propositional.tex';       SourceBlob='c9e0eb0ce86616c6bc79ccd639271fb2237e2375'; BlobHash='c6332d0af2635bb1c79d1f0e418f26472cdf1022ed23818ca51e9e1226889810'; SourceHash='8d19f7612edbb87db30f052b75e8208638a5c68570ef05faf6332111fbbc69fe'; TargetHash='a968d3270917509fb86700d86f252da796a932332858bb8a085296dfa7fe95d0' }
    [pscustomobject]@{ Id='OLP-0115'; Name='axioms-rules-quantifiers.tex';         SourceBlob='046dd4b36ea2a6c8bd6145953326e79d4d1fe66e'; BlobHash='fa0af48f98b58f2c7b5df8aa80cf2e4981936e237594ddce342e826bbca2ddc8'; SourceHash='e860523ec9605b17fb155fccbb22e644837c26de84ab11439422af805a26e2b3'; TargetHash='00fd11687f1f6bc10d4a00b5276c35e8aee05f66ea0a9019f09501623b718cc1' }
    [pscustomobject]@{ Id='OLP-0116'; Name='proving-things.tex';                  SourceBlob='d3dcd56749dc7876722075559cf9ec66aba64d5a'; BlobHash='23ad39fb3af69f934bb4410a53b692e1e589e5a12ecb757a219ee3e5dc4c6a56'; SourceHash='ac5dc1913eb14bc8d0ba0adb9d45d08b0882f02c4d7f152b654fc153f61fb1a7'; TargetHash='5c885977e1c8b31d2c7472951ba0c56294f11a51948d0471e19e18032e0255fb' }
    [pscustomobject]@{ Id='OLP-0117'; Name='proving-things-quant.tex';            SourceBlob='bea1d636ade4b4942457df3bf3fdd616f4331f57'; BlobHash='f0e9a893cec5f94f8d48ae6e7ca2c46ad04726c98a03fa33487c9a5c263d0c10'; SourceHash='afb6d653daa62d083e07ff556fdde130783b2643fdd23270e1ae0e1ec0140767'; TargetHash='72885fc0cd43f42a70bedf6fdf01a488e974c233f6326ab2df53148b7651b664' }
    [pscustomobject]@{ Id='OLP-0118'; Name='proof-theoretic-notions.tex';         SourceBlob='d36ce9e4798829c23718d13fa30550aeaf922c29'; BlobHash='0afb9df4b5f0f5c1e892cf411d126f45acce94cfbdc9087e4bd37cb851cc370b'; SourceHash='d5cd7ef578090b935af9013ba65f020ea8c043b95ec17ed9a758a01129bbf859'; TargetHash='0cde205089a80ce92a16b6396501e9686ad28d3e65f620586cc907918fced36f' }
    [pscustomobject]@{ Id='OLP-0119'; Name='deduction-theorem.tex';              SourceBlob='2e2ee0130e335a105b941daf8a84c107df7bbb2d'; BlobHash='ef122fcfc1a8c24e89cf5abe30efa11bcd0a1cc3ed9fca2426618e9174481780'; SourceHash='f74129e7541a9452530ebc0ab630c8763cd0d4177532baf43cd249c635642cd4'; TargetHash='102ce64d4034f6b914cc93b843e7c73c3354b0b8d3fba25a70be0ffa4b49b78b' }
    [pscustomobject]@{ Id='OLP-0120'; Name='deduction-theorem-quantifiers.tex';  SourceBlob='48e057a3e5478ab3b50d0b6bec4c50fcc55dc0ed'; BlobHash='79f2ddf58916652493c2892078b01dd53ae1691a97e28cfed043cbe285d11888'; SourceHash='0da5dfe61f218d9ef0820e07f1e6c0d71ef4e912d010e83e7484690bdd9af1e7'; TargetHash='cd80372bb1abdbf88fe8ef34268239258484559adeeb5735f5c2b445c2472030' }
    [pscustomobject]@{ Id='OLP-0121'; Name='provability-consistency.tex';         SourceBlob='5de407f30a432c84bc0c76df20c611d279c5475c'; BlobHash='22a6a04d9ab4298d762efd6bf2041fa9bf3f2d91c6803b744458812c232cdacc'; SourceHash='069b652fa3cf1c8e7719ae95d355398b866c9ecf42ff747b755ddbf5fd3b6eef'; TargetHash='9a5f29d51ddc4b455c8ea911c67935363ec1c612d72301ffdd159161abcf38bc' }
    [pscustomobject]@{ Id='OLP-0122'; Name='provability-propositional.tex';       SourceBlob='94086f3bf11b4866fe9e205ba3ca7e26fb34ab0b'; BlobHash='25274e10fe6d96292fe2c701b7af38291dd1d98de12a62ef385a5efd1c413007'; SourceHash='4dd07507288e361d9d65dcbb7c3de67f4e3c83e9853b6d9032dcc9cba3cef187'; TargetHash='0c6bedbe66b584de12a4421c1474ba80d838d9687f98eb2a4ce2e907bcd17a2a' }
    [pscustomobject]@{ Id='OLP-0123'; Name='provability-quantifiers.tex';         SourceBlob='2e60b409e16a4e2b301144df1fbe593e21004104'; BlobHash='07225de499f34bd17eec7586fc9bcc59e98ea3cfa064172091fa66a336bf20b6'; SourceHash='a0c03c490e2874b9946b5ff3942c8a4ba73696d13cca2b30e84a19d17dfb3066'; TargetHash='311b6f11ef04d8bbfc27d3ad00e5173c8aefa12c493ac6760d22d5f5d54f21f6' }
    [pscustomobject]@{ Id='OLP-0124'; Name='soundness.tex';                       SourceBlob='ff619e701406a54781ce042a21c1a6f993e5c482'; BlobHash='b5a11dd6a46306a767149f694f099bd9f57396013b4dfe67965e68ccae411ecb'; SourceHash='a3a783ae2add6b2420527ad65c82eb6a5e0c02ac8a44e3b34b757bc27985c1cf'; TargetHash='14c64cb630ca31848cf3f9bb6a891feb1e32da8b9100fc797a5ad3701bbe19fa' }
    [pscustomobject]@{ Id='OLP-0125'; Name='identity.tex';                        SourceBlob='82635689d664a0147bd2df4a54dc0ebe9cae7c3a'; BlobHash='9a4f25fcf00baab5d8d5f05e7fe2315ca9f4ceaa39a67551489a5130b9b8a2d4'; SourceHash='424d98f16806276deeb9cc0c5e0d1f70d25dd2026f0fe25f03d65d1cde1d69e1'; TargetHash='374b7ce8182cf8a6d0a8dc2c7708d23ff989adc2768b360f678ba003066a337f' }
)

$sourceDir = Join-Path $repoRoot ($relativeDir -replace '/', '\')
$targetDir = Join-Path $localeRoot ($relativeDir -replace '^content/', 'content/' -replace '/', '\')
$checks = 0
$sourceCorrectionClasses = 0
$sourceCorrectionOccurrences = 0
$targetPositiveAssertions = 0
$targetRejectedAssertions = 0
$totals = [ordered]@{
    commands = 0
    environments = 0
    semantic_tokens = 0
    labels = 0
    references = 0
    citations = 0
    assets = 0
    imports = 0
    math_skeletons = 0
    math_environments = 0
    formal_structures = 0
    localized_file_ids = 0
    localized_chapter_ids = 0
}

function Normalize-Newlines {
    param([Parameter(Mandatory)][string]$Text)
    return ($Text -replace "`r`n", "`n" -replace "`r", "`n")
}

function Get-Sha256 {
    param([Parameter(Mandatory)][string]$Path)
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function Get-BytesSha256 {
    param([Parameter(Mandatory)][byte[]]$Bytes)
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        return ([BitConverter]::ToString($sha.ComputeHash($Bytes))).Replace('-', '').ToLowerInvariant()
    } finally {
        $sha.Dispose()
    }
}

function Get-TextDigest {
    param([Parameter(Mandatory)][AllowEmptyCollection()][string[]]$Items)
    return Get-BytesSha256 -Bytes ([Text.Encoding]::UTF8.GetBytes(($Items -join "`n")))
}

function Invoke-GitBytes {
    param([Parameter(Mandatory)][string[]]$Arguments)
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
        if ($process.ExitCode -ne 0) {
            throw "git $($Arguments -join ' ') failed: $errorText"
        }
        return ,$memory.ToArray()
    } finally {
        $memory.Dispose()
        $process.Dispose()
    }
}

function Assert-Exact {
    param(
        [Parameter(Mandatory)][bool]$Condition,
        [Parameter(Mandatory)][string]$Name,
        [string]$Detail = ''
    )
    if (-not $Condition) { throw "FAIL $Name $Detail" }
    $script:checks++
    if ($Detail.Length -gt 0) { Write-Output "PASS $Name $Detail" }
    else { Write-Output "PASS $Name" }
}

function Get-UnescapedBraceBalance {
    param([Parameter(Mandatory)][string]$Text)
    $balance = 0
    $inComment = $false
    for ($index = 0; $index -lt $Text.Length; $index++) {
        $character = $Text[$index]
        if ($inComment) {
            if ($character -eq "`n") { $inComment = $false }
            continue
        }
        $slashes = 0
        for ($left = $index - 1; $left -ge 0 -and $Text[$left] -eq '\'; $left--) { $slashes++ }
        $escaped = (($slashes % 2) -eq 1)
        if ($character -eq '%' -and -not $escaped) { $inComment = $true; continue }
        if ($escaped) { continue }
        if ($character -eq '{') { $balance++ }
        elseif ($character -eq '}') { $balance-- }
        if ($balance -lt 0) { return $balance }
    }
    return $balance
}

function Remove-TexComments {
    param([Parameter(Mandatory)][string]$Text)
    $result = [Text.StringBuilder]::new()
    $normalized = Normalize-Newlines $Text
    foreach ($line in ($normalized -split "`n", 0, 'SimpleMatch')) {
        $cut = -1
        for ($index = 0; $index -lt $line.Length; $index++) {
            if ($line[$index] -ne '%') { continue }
            $slashes = 0
            for ($left = $index - 1; $left -ge 0 -and $line[$left] -eq '\'; $left--) { $slashes++ }
            if (($slashes % 2) -eq 0) { $cut = $index; break }
        }
        if ($cut -ge 0) { [void]$result.Append($line.Substring(0, $cut)) }
        else { [void]$result.Append($line) }
        [void]$result.Append("`n")
    }
    return $result.ToString()
}

function Get-Sequence {
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string]$Pattern,
        [string]$Group = 'value'
    )
    return @([regex]::Matches(
        $Text,
        $Pattern,
        [Text.RegularExpressions.RegexOptions]::Singleline
    ) | ForEach-Object { $_.Groups[$Group].Value })
}

function Assert-Sequence {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Expected,
        [Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Actual
    )
    if ($Expected.Count -ne $Actual.Count) {
        throw "$Name count mismatch: source=$($Expected.Count), target=$($Actual.Count)"
    }
    for ($index = 0; $index -lt $Expected.Count; $index++) {
        if ([string]$Expected[$index] -cne [string]$Actual[$index]) {
            throw "$Name mismatch at index $index`nSOURCE: $($Expected[$index])`nTARGET: $($Actual[$index])"
        }
    }
    $script:checks++
    Write-Output "PASS $Name count=$($Expected.Count)"
}

function Replace-Exact {
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string]$Old,
        [Parameter(Mandatory)][string]$New,
        [Parameter(Mandatory)][int]$ExpectedCount,
        [Parameter(Mandatory)][string]$Name
    )
    $actualCount = ([regex]::Matches($Text, [regex]::Escape($Old))).Count
    if ($actualCount -ne $ExpectedCount) {
        throw "$Name frozen-source occurrence mismatch: expected=$ExpectedCount actual=$actualCount"
    }
    $script:sourceCorrectionClasses++
    $script:sourceCorrectionOccurrences += $actualCount
    return $Text.Replace($Old, $New)
}

function Get-CorrectedSourceForReplay {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Text
    )
    $result = Normalize-Newlines $Text
    switch ($Name) {
        'rules-and-proofs.tex' {
            $result = Replace-Exact $result 'a step~$A_i$ in !!a{derivation}' `
                'a step~$!A_i$ in !!a{derivation}' 1 'rules/formula-marker-A_i'
        }
        'axioms-rules-quantifiers.tex' {
            $result = Replace-Exact $result `
                'does not occur in~$\Gamma$ or~$!B$, then' `
                'does not occur in~$\Gamma$, $!B$, or~$!A(x)$, then' `
                2 'quantifier-rules/generalized-matrix-freshness'
        }
        'proving-things.tex' {
            $result = Replace-Exact $result 'Our only rule is~MP, which' `
                'The rule needed here is~MP, which' 1 'examples/FOL-rule-scope'
        }
        'proof-theoretic-notions.tex' {
            $result = Replace-Exact $result `
                'satisfaction of !!{sentence}s in !!{structure}s,' `
                'satisfaction of !!{sentence}s in \iftag{FOL}{!!{structure}s}{valuations},' `
                1 'notions/PL-valuation-branch'
            $result = Replace-Exact $result '$B_i = !A$' '$!B_i = !A$' `
                1 'notions/formula-marker-B_i'
            $result = Replace-Exact $result 'by the same rule which' `
                'by the same justification that' 1 'notions/transitivity-justification'
            $result = Replace-Exact $result `
                'or follows from previous !!{formula}s by modus ponens.' `
                'or follows from previous !!{formula}s by a rule of inference.' `
                1 'notions/FOL-compactness-inference-scope'
        }
        'deduction-theorem.tex' {
            $result = Replace-Exact $result `
                'either $\in \Gamma \cup \{!A\}$ or is an axiom.' `
                'either $!B \in \Gamma \cup \{!A\}$ or is an axiom.' `
                1 'deduction/base-membership-subject'
            $result = Replace-Exact $result 'the last !!{sentence}~$!A' `
                'the last !!{formula}~$!A' 1 'deduction/formula-not-sentence'
            $old = 'ponens. (If it is not justified by modus ponens, $!B in \Gamma$, $!B' -replace ' in ', ' \in '
            $old += "`n" + '\ident !A$, or $!B$ is an axiom, and the same reasoning as in the'
            $old += "`n" + 'induction basis applies.) Then some previous steps in the'
            $new = 'ponens. (If it is not justified by modus ponens\iftag{FOL}{ or~\QR}{}, $!B \in \Gamma$, $!B'
            $new += "`n" + '\ident !A$, or $!B$ is an axiom, and the same reasoning as in the'
            $new += "`n" + 'induction basis applies.) \iftag{FOL}{The~\QR{} case is handled in the next section.}{} Then some previous steps in the'
            $result = Replace-Exact $result $old $new 1 'deduction/FOL-QR-case-routing'
            $result = Replace-Exact $result `
                '\lif (!A \lif !C)$; \ollabel{derivfacts:a}' `
                '\lif (!A \lif !C))$; \ollabel{derivfacts:a}' `
                1 'deduction/derivfacts-closing-parenthesis'
        }
        'deduction-theorem-quantifiers.tex' {
            $result = Replace-Exact $result `
                '$!C$, $!A$, or $\Gamma$. We' `
                '$!C$, $!A$, $!D(x)$, or $\Gamma$. We' `
                1 'deduction-quantifiers/generalized-matrix-freshness'
            $result = Replace-Exact $result `
                '\lforall[x][!D(x)]),\\' `
                '\lforall[x][!D(x)])),\\' `
                1 'deduction-quantifiers/closing-parenthesis'
            $result = Replace-Exact $result 'i.e., $\Gamma \Proves !B$.' `
                'i.e., $\Gamma \Proves !A \lif !B$.' `
                1 'deduction-quantifiers/final-conclusion'
        }
        'provability-propositional.tex' {
            $result = Replace-Exact $result `
                '\olref[prp]{ax:land1} and \olref[prp]{ax:land1}' `
                '\olref[prp]{ax:land1} and \olref[prp]{ax:land2}' `
                1 'provability-propositional/right-conjunction-reference'
            $result = Replace-Exact $result '\olref[prp]{ax:lnot1} we get' `
                '\olref[prp]{ax:lnot2} we get' `
                1 'provability-propositional/negation-reference'
            $result = Replace-Exact $result ('modus' + "`n" + '    ponsens.') `
                'modus ponens.' `
                1 'provability-propositional/modus-ponens-typo'
        }
        'provability-quantifiers.tex' {
            $result = Replace-Exact $result `
                '$c$ does not occur in $\Gamma$ or~$\top$, we get' `
                '$c$ does not occur in $\Gamma$, $\top$, or~$!A(x)$, we get' `
                1 'provability-quantifiers/QR-premises'
            $result = Replace-Exact $result `
                'By the deduction theorem again, $\Gamma \Proves' `
                'Since the truth axiom is available, modus ponens gives $\Gamma \Proves' `
                1 'provability-quantifiers/truth-axiom-MP-step'
            $result = Replace-Exact $result `
                ('\ollabel{prop:provability-quantifiers}' + "`n" + '\begin{tagenumerate}{prvEx,prvAll}') `
                ('\ollabel{prop:provability-quantifiers}' + "`n" + 'For every closed term~$t$:' + "`n" + '\begin{tagenumerate}{prvEx,prvAll}') `
                1 'provability-quantifiers/closed-term-restriction'
        }
        'soundness.tex' {
            $old = 'By induction on the length of the !!{derivation} of $!A$ from' + "`n" +
                '$\Gamma$. If there are no steps justified by inferences, then all'
            $new = 'By induction on the number of steps in the !!{derivation} of $!A$ from' + "`n" +
                '$\Gamma$ that are justified by inference rules. If there are no steps justified by inferences, then all'
            $result = Replace-Exact $result $old $new 1 'soundness/induction-measure'
            $result = Replace-Exact $result '\lforall[x][B(x)]' `
                '\lforall[x][!B(x)]' 2 'soundness/formula-markers-Bx'
            $result = Replace-Exact $result '\Sat{M''}{B(c)}' `
                '\Sat{M''}{!B(c)}' 1 'soundness/formula-marker-Bc'
            $result = Replace-Exact $result ('$!D \in' + "`n" + '\Gamma$ by') `
                ('$!D \in' + "`n" + '\Gamma \cup \{!C\}$ by') `
                1 'soundness/satisfaction-carrier'
        }
        'identity.tex' {
            $result = Replace-Exact $result '% Chapter: axiomatic-proofs' `
                '% Chapter: axiomatic-deduction' 1 'identity/chapter-comment'
            $result = Replace-Exact $result 'for any term $t$ and set~$\Gamma$.' `
                'for any closed term $t$ and set~$\Gamma$.' `
                1 'identity/reflexivity-closed-term'
            $result = Replace-Exact $result `
                '  If $\Gamma \Proves !A(t_1)$ and $\Gamma \Proves' `
                '  For closed terms $t_1$ and $t_2$, if $\Gamma \Proves !A(t_1)$ and $\Gamma \Proves' `
                1 'identity/substitution-closed-terms'
        }
    }
    return $result
}

function Normalize-TranslationStructures {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Text
    )
    $result = $Text
    if ($Name -ceq 'deduction-theorem.tex') {
        # Indonesian expresses membership predicatively here. Split the
        # corrected English membership formula at the same semantic boundary.
        $result = $result.Replace(
            '$!B \in \Gamma \cup \{!A\}$',
            '$\Gamma \cup \{!A\}$ contains !B')
    }
    if ($Name -ceq 'soundness.tex') {
        # Indonesian has no direct morphology-token counterpart for the
        # English lexical item "free for"; its reader prose says "bebas untuk".
        $result = $result.Replace('!!{free for}', 'free for')
        # Indonesian reorders the two noun phrases at the modus-ponens branch:
        # one derivation token precedes the pair of formula tokens.
        $result = $result.Replace(
            'then there are !!{formula}s $!B$ and $!B \lif !A$ in the' + "`n" +
                '!!{derivation},',
            'then the !!{derivation} contains !!{formula}s $!B$ and $!B \lif !A$,')
    }
    return $result
}

function Replace-ProseArgument {
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string]$Command
    )
    $needle = "\$Command{"
    $builder = [Text.StringBuilder]::new()
    $index = 0
    while ($index -lt $Text.Length) {
        if (($index + $needle.Length -le $Text.Length) -and
            ($Text.Substring($index, $needle.Length) -ceq $needle)) {
            [void]$builder.Append("\$Command{<TEXT>}")
            $index += $needle.Length
            $depth = 1
            while ($index -lt $Text.Length -and $depth -gt 0) {
                if ($Text[$index] -eq '\' -and $index + 1 -lt $Text.Length) {
                    $index += 2
                    continue
                }
                if ($Text[$index] -eq '{') { $depth++ }
                elseif ($Text[$index] -eq '}') { $depth-- }
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

function Normalize-Math {
    param([Parameter(Mandatory)][string]$Text)
    $result = Replace-ProseArgument $Text 'text'
    $result = Replace-ProseArgument $result 'intertext'
    $result = Replace-ProseArgument $result 'emph'
    return [regex]::Replace($result, '[\s~]+', '')
}

function Get-MathSkeletons {
    param([Parameter(Mandatory)][string]$Text)
    $items = [Collections.Generic.List[string]]::new()
    foreach ($match in [regex]::Matches($Text, '(?<!\\)\$(.*?)(?<!\\)\$', 'Singleline')) {
        $items.Add('INLINE:' + (Normalize-Math $match.Value))
    }
    foreach ($match in [regex]::Matches($Text, '\\\[(.*?)\\\]', 'Singleline')) {
        $items.Add('DISPLAY:' + (Normalize-Math $match.Value))
    }
    return @($items)
}

function Get-MathEnvironmentStructures {
    param([Parameter(Mandatory)][string]$Text)
    return @([regex]::Matches(
        $Text,
        '\\begin\{(?<environment>align\*?|multline\*?|equation\*?)\}(?<body>.*?)\\end\{\k<environment>\}',
        [Text.RegularExpressions.RegexOptions]::Singleline
    ) | ForEach-Object {
        $body = Replace-ProseArgument $_.Groups['body'].Value 'intertext'
        $_.Groups['environment'].Value + ':' + (Normalize-Math $body)
    })
}

function Get-CommandSequence {
    param([Parameter(Mandatory)][string]$Text)
    # References are checked in their own exact ordered sequence and excluded
    # here so the aggregate counts each syntactic object exactly once.
    return @((Get-Sequence $Text '(?<value>\\[A-Za-z@]+|\\.)') |
        Where-Object { $_ -cne '\olref' -and $_ -cne '\Olref' })
}

function Get-SemanticTokenNames {
    param([Parameter(Mandatory)][string]$Text)
    return @([regex]::Matches(
        $Text,
        '!!(?:\^)?(?:a|A)?\{(?<value>[^{}]+)\}(?:s|d)?',
        [Text.RegularExpressions.RegexOptions]::Singleline
    ) | ForEach-Object { [regex]::Replace($_.Groups['value'].Value, '\s+', ' ') })
}

function Get-FormalStructures {
    param([Parameter(Mandatory)][string]$Text)
    return @([regex]::Matches(
        $Text,
        '\\begin\{(?<environment>prooftree|oltableau|derivation)\}(?<body>.*?)\\end\{\k<environment>\}',
        [Text.RegularExpressions.RegexOptions]::Singleline
    ) | ForEach-Object {
        $body = $_.Groups['body'].Value
        $commands = @(Get-CommandSequence $body) -join ','
        $math = @(Get-MathSkeletons $body) -join [char]0x241f
        $ampersands = ([regex]::Matches($body, '&')).Count
        $rowTerminators = ([regex]::Matches($body, '\\\\')).Count
        '{0}|ampersands={1}|rows={2}|commands={3}|math={4}' -f `
            $_.Groups['environment'].Value, $ampersands, $rowTerminators,
            $commands, $math
    })
}

function Assert-LiteralCount {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string]$Literal,
        [Parameter(Mandatory)][int]$Expected
    )
    $actual = ([regex]::Matches($Text, [regex]::Escape($Literal))).Count
    if ($actual -ne $Expected) {
        throw "$Name literal occurrence mismatch: expected=$Expected actual=$actual`nLITERAL: $Literal"
    }
    $script:checks++
    Write-Output "PASS $Name count=$actual"
}

function Assert-TargetCorrection {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Required,
        [Parameter(Mandatory)][int]$RequiredCount,
        [Parameter(Mandatory)][string]$Rejected
    )
    $text = Normalize-Newlines ([IO.File]::ReadAllText($Path))
    Assert-LiteralCount "correction-positive/$Name" $text $Required $RequiredCount
    $script:targetPositiveAssertions++
    Assert-LiteralCount "correction-rejected/$Name" $text $Rejected 0
    $script:targetRejectedAssertions++
}

$commitType = @(& git -C $repoRoot cat-file -t $expectedCommit 2>$null)
Assert-Exact (($LASTEXITCODE -eq 0) -and $commitType.Count -eq 1 -and $commitType[0] -ceq 'commit') `
    'frozen-source-commit-object' $expectedCommit
Assert-Exact (Test-Path -LiteralPath $manifestPath) 'closure-manifest-present' $manifestPath

$manifest = Import-Csv -LiteralPath $manifestPath
$manifestBatch = @($manifest | Where-Object {
    [int]$_.stable_order -ge 112 -and [int]$_.stable_order -le 125
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
}

$finalSource = @{}
$finalTarget = @{}
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
        [int]$row.stable_order -eq (112 + $unitIndex) -and
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
        $LASTEXITCODE -eq 0 -and $resolvedBlob.Count -eq 1 -and
        $resolvedBlob[0] -ceq $unit.SourceBlob
    ) "$($unit.Id)/source-git-object" $unit.SourceBlob
    $blobType = @(& git -C $repoRoot cat-file -t $unit.SourceBlob 2>$null)
    Assert-Exact (
        $LASTEXITCODE -eq 0 -and $blobType.Count -eq 1 -and $blobType[0] -ceq 'blob'
    ) "$($unit.Id)/source-object-type" 'blob'

    $blobBytes = Invoke-GitBytes @('cat-file', 'blob', $unit.SourceBlob)
    Assert-Exact ((Get-BytesSha256 $blobBytes) -ceq $unit.BlobHash) `
        "$($unit.Id)/source-git-object-sha256" $unit.BlobHash
    Assert-Exact ((Get-Sha256 $targetPath) -ceq $unit.TargetHash) `
        "$($unit.Id)/target-hash" $unit.TargetHash

    $sourceRaw = Normalize-Newlines ([Text.Encoding]::UTF8.GetString($blobBytes))
    $targetRaw = Normalize-Newlines ([IO.File]::ReadAllText($targetPath))
    $correctedSource = Get-CorrectedSourceForReplay $unit.Name $sourceRaw
    $replaySource = Normalize-TranslationStructures $unit.Name $correctedSource
    $source = Remove-TexComments $replaySource
    $target = Remove-TexComments $targetRaw
    $finalSource[$unit.Name] = $sourceRaw
    $finalTarget[$unit.Name] = $targetRaw

    Assert-Exact (
        (Get-UnescapedBraceBalance $sourceRaw) -eq 0 -and
        (Get-UnescapedBraceBalance $targetRaw) -eq 0
    ) "$($unit.Id)/balanced-braces"

    $sourceCommands = @(Get-CommandSequence $source)
    $targetCommands = @(Get-CommandSequence $target)
    Assert-Sequence "$($unit.Id)/normalized-command-sequence" $sourceCommands $targetCommands
    $totals.commands += $targetCommands.Count

    foreach ($entry in $literalPatterns.GetEnumerator()) {
        $sourceSequence = @(Get-Sequence $source $entry.Value)
        $targetSequence = @(Get-Sequence $target $entry.Value)
        Assert-Sequence "$($unit.Id)/ordered-$($entry.Key)" $sourceSequence $targetSequence
        $totals[$entry.Key] += $targetSequence.Count
    }

    $sourceTokens = @(Get-SemanticTokenNames $source)
    $targetTokens = @(Get-SemanticTokenNames $target)
    Assert-Sequence "$($unit.Id)/semantic-token-name-sequence" $sourceTokens $targetTokens
    $totals.semantic_tokens += $targetTokens.Count

    $sourceFileIds = @(Get-Sequence $source '\\olfileid\{(?<value>[^{}]+\}\{[^{}]+\}\{[^{}]+)\}')
    $targetFileIds = @(Get-Sequence $target '\\olfileid\[id\]\{(?<value>[^{}]+\}\{[^{}]+\}\{[^{}]+)\}')
    Assert-Sequence "$($unit.Id)/localized-file-ids" $sourceFileIds $targetFileIds
    $totals.localized_file_ids += $targetFileIds.Count

    $sourceChapterIds = @(Get-Sequence $source '\\olchapter\{(?<value>[^{}]+\}\{[^{}]+)\}\{')
    $targetChapterIds = @(Get-Sequence $target '\\olchapter\[id\]\{(?<value>[^{}]+\}\{[^{}]+)\}\{')
    Assert-Sequence "$($unit.Id)/localized-chapter-ids" $sourceChapterIds $targetChapterIds
    $totals.localized_chapter_ids += $targetChapterIds.Count

    $sourceMath = @(Get-MathSkeletons $source)
    $targetMath = @(Get-MathSkeletons $target)
    Assert-Sequence "$($unit.Id)/normalized-math-skeletons" $sourceMath $targetMath
    $totals.math_skeletons += $targetMath.Count

    $sourceMathEnvironments = @(Get-MathEnvironmentStructures $source)
    $targetMathEnvironments = @(Get-MathEnvironmentStructures $target)
    Assert-Sequence "$($unit.Id)/normalized-math-environments" `
        $sourceMathEnvironments $targetMathEnvironments
    $totals.math_environments += $targetMathEnvironments.Count

    $sourceFormal = @(Get-FormalStructures $source)
    $targetFormal = @(Get-FormalStructures $target)
    Assert-Sequence "$($unit.Id)/normalized-formal-structures" $sourceFormal $targetFormal
    $totals.formal_structures += $targetFormal.Count

    $sourceDigestRecords.Add("$($unit.Id)|$($unit.SourceBlob)|$($unit.BlobHash)|$($unit.SourceHash)|$sourceRelative")
    $targetDigestRecords.Add("$($unit.Id)|$($unit.TargetHash)|$targetRelative")
}

$allTarget = ($units | ForEach-Object { $finalTarget[$_.Name] }) -join "`n"
Assert-Exact (-not [regex]::IsMatch($allTarget, '\\ol(?:fileid|chapter)(?!\[id\])')) `
    'batch/all-locale-identifiers-id'

# Exact positive/rejected target assertions. Replace-Exact above independently
# proves that each rejected defect exists in the frozen source object with the
# expected path-local occurrence count. These pairs prove that the reviewed
# target contains the admitted correction and does not retain the defect.
$corrections = @(
    [pscustomobject]@{ Name='rules/formula-marker-A_i'; File='rules-and-proofs.tex'; Count=1; Required='langkah~$!A_i$ dalam !!a{derivation}'; Rejected='langkah~$A_i$ dalam !!a{derivation}' }
    [pscustomobject]@{ Name='quantifier-rules/generalized-matrix-freshness'; File='axioms-rules-quantifiers.tex'; Count=2; Required='tidak muncul dalam~$\Gamma$, $!B$, ataupun~$!A(x)$'; Rejected='tidak muncul dalam~$\Gamma$ ataupun~$!B$' }
    [pscustomobject]@{ Name='examples/FOL-rule-scope'; File='proving-things.tex'; Count=1; Required='Aturan yang' + "`n" + 'kita perlukan di sini adalah~MP'; Rejected='Satu-satunya aturan kita adalah~MP' }
    [pscustomobject]@{ Name='notions/PL-valuation-branch'; File='proof-theoretic-notions.tex'; Count=1; Required='\iftag{FOL}{!!{structure}s}{valuasi}'; Rejected='di dalam !!{structure}s' }
    [pscustomobject]@{ Name='notions/formula-marker-B_i'; File='proof-theoretic-notions.tex'; Count=2; Required='$!B_i = !A$'; Rejected='$B_i = !A$' }
    [pscustomobject]@{ Name='notions/transitivity-justification'; File='proof-theoretic-notions.tex'; Count=1; Required='oleh pembenaran yang sama dengan yang membenarkan~$!A_k = !A$'; Rejected='oleh aturan yang sama yang membenarkan~$!A_k = !A$' }
    [pscustomobject]@{ Name='notions/FOL-compactness-inference-scope'; File='proof-theoretic-notions.tex'; Count=1; Required='melalui suatu aturan inferensi.'; Rejected='melalui modus ponens.' }
    [pscustomobject]@{ Name='deduction/base-membership-subject'; File='deduction-theorem.tex'; Count=1; Required='$!B$ merupakan anggota' + "`n" + '$\Gamma \cup \{!A\}$ atau sebuah aksioma.'; Rejected='maka merupakan anggota' + "`n" + '$\Gamma \cup \{!A\}$ atau sebuah aksioma.' }
    [pscustomobject]@{ Name='deduction/formula-not-sentence'; File='deduction-theorem.tex'; Count=1; Required='!!{formula} terakhir~$!A \lif !B$'; Rejected='!!{sentence} terakhir~$!A \lif !B$' }
    [pscustomobject]@{ Name='deduction/FOL-QR-case-routing'; File='deduction-theorem.tex'; Count=1; Required='Jika langkah itu tidak dijustifikasi' + "`n" + 'oleh modus ponens\iftag{FOL}{ ataupun aturan~\QR}{}, maka'; Rejected='Jika langkah itu tidak dijustifikasi' + "`n" + 'oleh modus ponens, maka' }
    [pscustomobject]@{ Name='deduction/derivfacts-closing-parenthesis'; File='deduction-theorem.tex'; Count=1; Required='\lif (!A \lif !C))$; \ollabel{derivfacts:a}'; Rejected='\lif (!A \lif !C)$; \ollabel{derivfacts:a}' }
    [pscustomobject]@{ Name='deduction-quantifiers/generalized-matrix-freshness'; File='deduction-theorem-quantifiers.tex'; Count=1; Required='$!C$, $!A$,' + "`n" + '$!D(x)$, ataupun $\Gamma$.'; Rejected='$!C$, $!A$, ataupun $\Gamma$.' }
    [pscustomobject]@{ Name='deduction-quantifiers/closing-parenthesis'; File='deduction-theorem-quantifiers.tex'; Count=1; Required='\lforall[x][!D(x)])),\\'; Rejected='\lforall[x][!D(x)]),\\' }
    [pscustomobject]@{ Name='deduction-quantifiers/final-conclusion'; File='deduction-theorem-quantifiers.tex'; Count=1; Required='yakni, $\Gamma \Proves !A \lif !B$.'; Rejected='yakni, $\Gamma \Proves !B$.' }
    [pscustomobject]@{ Name='provability-propositional/right-conjunction-reference'; File='provability-propositional.tex'; Count=1; Required='\olref[prp]{ax:land1} dan' + "`n" + '    \olref[prp]{ax:land2}'; Rejected='\olref[prp]{ax:land1} dan' + "`n" + '    \olref[prp]{ax:land1}' }
    [pscustomobject]@{ Name='provability-propositional/negation-reference'; File='provability-propositional.tex'; Count=1; Required='Dari \olref[prp]{ax:lnot2}'; Rejected='Dari \olref[prp]{ax:lnot1}' }
    [pscustomobject]@{ Name='provability-propositional/modus-ponens-typo'; File='provability-propositional.tex'; Count=3; Required='modus ponens.'; Rejected='modus ponsens.' }
    [pscustomobject]@{ Name='provability-quantifiers/QR-premises'; File='provability-quantifiers.tex'; Count=1; Required='$c$ tidak muncul dalam $\Gamma$, $\top$, ataupun~$!A(x)$'; Rejected='$c$ tidak muncul dalam $\Gamma$ ataupun~$\top$' }
    [pscustomobject]@{ Name='provability-quantifiers/truth-axiom-MP-step'; File='provability-quantifiers.tex'; Count=1; Required='Karena aksioma' + "`n" + 'kebenaran tersedia, modus ponens selanjutnya memberikan'; Rejected='Menurut teorema deduksi sekali lagi' }
    [pscustomobject]@{ Name='provability-quantifiers/closed-term-restriction'; File='provability-quantifiers.tex'; Count=1; Required='Untuk setiap suku tertutup~$t$:'; Rejected='Untuk setiap suku~$t$:' }
    [pscustomobject]@{ Name='soundness/induction-measure'; File='soundness.tex'; Count=1; Required='induksi pada jumlah langkah dalam !!{derivation} dari' + "`n" + '$!A$ berdasarkan $\Gamma$ yang dijustifikasi oleh aturan inferensi.'; Rejected='induksi pada panjang !!{derivation} dari' }
    [pscustomobject]@{ Name='soundness/formula-markers-Bx'; File='soundness.tex'; Count=7; Required='\lforall[x][!B(x)]'; Rejected='\lforall[x][B(x)]' }
    [pscustomobject]@{ Name='soundness/formula-marker-Bc'; File='soundness.tex'; Count=3; Required='\Sat{M''}{!B(c)}'; Rejected='\Sat{M''}{B(c)}' }
    [pscustomobject]@{ Name='soundness/satisfaction-carrier'; File='soundness.tex'; Count=1; Required='$!D \in \Gamma \cup \{!C\}$'; Rejected='$!D \in \Gamma$ untuk setiap' }
    [pscustomobject]@{ Name='identity/chapter-comment'; File='identity.tex'; Count=1; Required='% Bab: axiomatic-deduction'; Rejected='% Bab: axiomatic-proofs' }
    [pscustomobject]@{ Name='identity/reflexivity-closed-term'; File='identity.tex'; Count=2; Required='untuk sebarang suku tertutup $t$'; Rejected='untuk sebarang suku $t$' }
    [pscustomobject]@{ Name='identity/substitution-closed-terms'; File='identity.tex'; Count=1; Required='Untuk suku-suku tertutup $t_1$ dan $t_2$'; Rejected='Untuk suku-suku $t_1$ dan $t_2$' }
)

foreach ($correction in $corrections) {
    Assert-TargetCorrection $correction.Name (Join-Path $targetDir $correction.File) `
        $correction.Required $correction.Count $correction.Rejected
}

Assert-Exact ($sourceCorrectionClasses -eq 27) 'batch/source-correction-class-count' 'count=27'
Assert-Exact ($sourceCorrectionOccurrences -eq 29) 'batch/source-correction-occurrence-count' 'count=29'
Assert-Exact ($corrections.Count -eq 27) 'batch/target-correction-pair-count' 'count=27'
Assert-Exact ($targetPositiveAssertions -eq 27 -and $targetRejectedAssertions -eq 27) `
    'batch/positive-rejected-assertion-counts' 'positive=27 rejected=27'

# Independently frozen aggregate counts prevent a weakened regex or an omitted
# unit from passing merely because source and target fail in the same way.
$expectedTotals = [ordered]@{
    commands = 1540
    environments = 250
    semantic_tokens = 142
    labels = 54
    references = 88
    citations = 0
    assets = 0
    imports = 13
    math_skeletons = 482
    math_environments = 6
    formal_structures = 5
    localized_file_ids = 21
    localized_chapter_ids = 2
}
foreach ($entry in $expectedTotals.GetEnumerator()) {
    Assert-Exact ($totals[$entry.Key] -eq $entry.Value) `
        "batch/frozen-total-$($entry.Key)" "count=$($entry.Value)"
}

$sourceSetDigest = Get-TextDigest @($sourceDigestRecords)
$targetSetDigest = Get-TextDigest @($targetDigestRecords)
foreach ($unit in $units) {
    Write-Output "TARGET_HASH $($unit.Id) $($unit.Name) $($unit.TargetHash)"
}
Write-Output ("STRUCTURAL_TOTALS commands={0} environments={1} semantic_tokens={2} labels={3} references={4} citations={5} assets={6} imports={7} math_skeletons={8} math_environments={9} formal_structures={10} localized_file_ids={11} localized_chapter_ids={12}" -f `
    $totals.commands, $totals.environments, $totals.semantic_tokens,
    $totals.labels, $totals.references, $totals.citations, $totals.assets,
    $totals.imports, $totals.math_skeletons, $totals.math_environments,
    $totals.formal_structures, $totals.localized_file_ids,
    $totals.localized_chapter_ids)
Write-Output "CORRECTION_TOTALS classes=$sourceCorrectionClasses source_occurrences=$sourceCorrectionOccurrences positive=$targetPositiveAssertions rejected=$targetRejectedAssertions"
Write-Output "BINDING_DIGESTS source_set_sha256=$sourceSetDigest target_set_sha256=$targetSetDigest"
Write-Output "AXIOMATIC_DEDUCTION_BATCH_REPLAY_OK files=$($units.Count) checks=$checks upstream=$expectedCommit closure=OLP-0112..OLP-0125"
