$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$localeRoot = $PSScriptRoot
$repoRoot = [IO.Path]::GetFullPath((Join-Path $localeRoot '..\..'))
$controlRoot = [IO.Path]::GetFullPath((Join-Path $repoRoot '..\_control'))
$manifestPath = Join-Path $controlRoot 'OPENLOGIC_CLOSURE_MANIFEST_20260812.csv'
$expectedCommit = '9620cc73f9c8e0ad003c514a5d3748f29611c4c0'

# SourceBlob freezes the immutable Git object. SourceHash freezes the
# normalized worktree bytes recorded by the closure manifest. TargetHash
# freezes the post-review Indonesian bytes; changing any of the three
# authorities makes this replay fail closed.
$units = @(
    [pscustomobject]@{ Id='OLP-0159'; Path='content/first-order-logic/syntax-and-semantics/semantics.tex';          SourceBlob='569227c7b5f6b44230c0392194f568b9e70d3e51'; SourceHash='d863c375746602be962b1b45545d8a51e72f9d0d9dca516f434152131b4107ec'; TargetHash='a9bf46b0f32cb4633cb1fb3552e2e7a2e519dfe619124f2648a3c4ca1774ef12' }
    [pscustomobject]@{ Id='OLP-0160'; Path='content/first-order-logic/syntax-and-semantics/intro-semantics.tex';    SourceBlob='bac67ec61bc04d95d8202dde15e79f4a1bef8323'; SourceHash='0bcf5a399c46716183aba26ed6d331abae45bdb63ed5bb26b3a7085b840e86e4'; TargetHash='3c6bdbfc0a9020e7ab5a797fba8c6062f35b8efb9cec5cc62f5b1248a66c7933' }
    [pscustomobject]@{ Id='OLP-0161'; Path='content/first-order-logic/syntax-and-semantics/structures.tex';         SourceBlob='5ffecb882e223ddc1affe5fef81cf8cd3d5342c1'; SourceHash='653be0fbc8ef1d61d9f39e7515bd1b1b1911f42147e0131a3235670e677cc241'; TargetHash='a9f1fc465009a8b3e38e46bccc115197af6688184463c3e6e377282c6ecf38c5' }
    [pscustomobject]@{ Id='OLP-0162'; Path='content/first-order-logic/syntax-and-semantics/covered-structures.tex'; SourceBlob='7205721e991a8d175bdccb9e615367f8571e3758'; SourceHash='47b8c3e2f2455d6fdefbf11157cae904e95c858545997fd9b22e7a2a8a1948d7'; TargetHash='45bfc051d07a91c2d5bc4f03b080265ff092e243fd7b56ce235b47b7ee5b181b' }
    [pscustomobject]@{ Id='OLP-0163'; Path='content/first-order-logic/syntax-and-semantics/satisfaction.tex';       SourceBlob='1f505fb63513659faa8075b0d19509226c950950'; SourceHash='e44b0bea8c5d130077516bc8d757f46d4b337517aab77049841581313820fd32'; TargetHash='38a4d1b51e3406b30c68c0ac32f2be1189322331406958d97132feabd842ab00' }
    [pscustomobject]@{ Id='OLP-0164'; Path='content/first-order-logic/syntax-and-semantics/assignments.tex';        SourceBlob='ed2c6c103dc13dbc2a31a780c04389e7b58fa4ed'; SourceHash='158d852e2ead50b060a48332cac8c72c475cfc206d3dab7aac24a01be3ff1771'; TargetHash='808427c766665df2107766266569acb123ccf23bdd35f11a1744aede965fdaec' }
    [pscustomobject]@{ Id='OLP-0165'; Path='content/first-order-logic/syntax-and-semantics/extensionality.tex';     SourceBlob='f1d9999e344f16881e372e2019001ef27f1064d4'; SourceHash='b96be00c844c1a06be3dc8c18e237fdb595ed60b18462b01bca43e6886d1da4d'; TargetHash='71dc6cec748ff3d6365144e240f1b2d0d30d96a3937d64d86b3ee959466c2203' }
    [pscustomobject]@{ Id='OLP-0166'; Path='content/first-order-logic/syntax-and-semantics/semantic-notions.tex';   SourceBlob='29823842c73b388dd545f47a95cafe15cc1165a0'; SourceHash='8b8740c064a3a876ff0cdf5dacd51bb8d3bbba87256fe49180de5f7c80fe08dd'; TargetHash='0c44c2f78686776ff359618bdee857c21854501c1bbb6f63992ecbc9e66ba370' }
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
        'content/first-order-logic/syntax-and-semantics/covered-structures.tex' {
            $result = Replace-RegexExact $result `
                '\\Value\{\\times\(\\Obj\{two\}, \+\(\\Obj\{three\},\\Obj\{zero\}\)\)\}\{M\} =\\\\' `
                '\Value{\times(\Obj{two}, +(\Obj{three},\Obj{zero}))}{M} \\' 1 `
                'covered-structures/remove-consecutive-equals'
        }
        'content/first-order-logic/syntax-and-semantics/satisfaction.tex' {
            $result = Replace-RegexExact $result `
                '\\iftag\{prvEx\}\{for at least one \$m \\in\s+\\Domain\{M\}\$\}\{for all' `
                '\iftag{prvEx}{for at least one $m \in \Domain{M}$, $\Sat{M}{!B(m)}$}{for all' 1 `
                'satisfaction/restore-existential-instance'
            $result = Replace-RegexExact $result `
                '\\tuple\{1, 3\} \\notin \\Assign\{R\}\{M\}\[s\]' `
                '\tuple{1, 3} \notin \Assign{R}{M}' 1 'satisfaction/remove-assignment-from-relation'
            $result = Replace-RegexExact $result `
                '\\Sat/\{M\}\{\\lforall\[x\]\[\\lnot\(\(R\(b,x\) \\lor R\(x,b\)\)\]\}\[s\]' `
                '\Sat/{M}{\lforall[x][\lnot(R(b,x) \lor R(x,b))]}[s]' 1 `
                'satisfaction/defEx-inner-parenthesis'
            $result = Replace-RegexExact $result `
                '\\Sat\{M\}\{\\lnot\\lforall\[x\]\[\\lnot\(\(R\(b,x\) \\lor\s+R\(x,b\)\)\]\}\[s\]' `
                '\Sat{M}{\lnot\lforall[x][\lnot(R(b,x) \lor R(x,b))]}[s]' 1 `
                'satisfaction/defEx-outer-parenthesis'
            $result = Replace-RegexExact $result `
                '\\Sat/\{M\}\{\\lexists\[x\]\[\(R\(b,x\) \\land R\(x,b\)\)\]\,\}\[s\]' `
                '\Sat/{M}{\lexists[x][(R(b,x) \land R(x,b))]}[s]' 1 `
                'satisfaction/defEx-stray-comma'
            $result = Replace-RegexExact $result `
                '\\Sat/\{M\}\{R\(a,x\)\}\[\\Subst\{s\}\{m\}\{x\}\]\$ for \$m = 2\$, \$3\$, or~\$4\$' `
                '\Sat/{M}{R(x,a)}[\Subst{s}{m}{x}]$ for $m = 2$, $3$, or~$4$' 1 `
                'satisfaction/defAll-antecedent'
            $result = Replace-RegexExact $result `
                'only \$m = 1\$\s+and \$ = 2\$' `
                'only $m = 1$ and $m = 2$' 1 'satisfaction/missing-m-before-two'
            $result = Replace-RegexExact $result `
                'So, for all \$n \\in \\Domain M\$, either' `
                'So, for all $m \in \Domain M$, either' 1 'satisfaction/outer-variable-m'
            $result = Replace-RegexExact $result `
                'namely \$n = 4\$, so that' `
                'namely $n = 4$ when $m = 1$, and $n = 1$ when $m = 2$, so that' 1 `
                'satisfaction/valid-witness-split'
        }
        'content/first-order-logic/syntax-and-semantics/assignments.tex' {
            $result = Replace-RegexExact $result 'sub-!!\{formula\}' '!!{subformula}' 1 `
                'assignments/localize-subformula-token'
            $result = Replace-RegexExact $result `
                '\\langle \\Value\{t_i\}\{M\}\[s_2\], \\ldots, \\Value\{t_k\}\{M\}\[s_2\] \\rangle' `
                '\langle \Value{t_1}{M}[s_2], \ldots, \Value{t_k}{M}[s_2] \rangle' 1 `
                'assignments/tuple-first-index'
            $result = Replace-RegexExact $result `
                '\$s_1'' = \\Subst\{s\}\{m\}\{x\}\$ and \$s_2'' =\s+\\Subst\{s\}\{m\}\{x\}\$' `
                '$s_1'' = \Subst{s_1}{m}{x}$ and $s_2'' = \Subst{s_2}{m}{x}$' 1 `
                'assignments/universal-variant-bases'
            $result = Replace-RegexExact $result `
                'set of !!\{sentence\}s~\$\\Gamma\$' 'set of !!{sentence}s' 1 `
                'assignments/remove-duplicate-Gamma'
        }
        'content/first-order-logic/syntax-and-semantics/extensionality.tex' {
            $result = Replace-RegexExact $result `
                'for every term,\s+\$\\Value\{t\}\{M_1\}\[s\]' `
                'for every term occurring in~$!A$, $\Value{t}{M_1}[s]' 1 `
                'extensionality/restrict-term-claim'
            $result = Replace-RegexExact $result `
                '\\Value\{\\Subst\{t\}\{t''\}\{x\}\}\{M\}\[s\]\s+= \\\\' `
                '\Value{\Subst{t}{t''}{x}}{M}[s] \\' 1 `
                'extensionality/remove-consecutive-equals'
            $result = Replace-RegexExact $result `
                '\$t''\$~a term, and \$s\$~a variable' `
                '$t''$~a term that is !!{free for}~$x$ in~$!A$, and $s$~a variable' 1 `
                'extensionality/free-for-premise'
        }
        'content/first-order-logic/syntax-and-semantics/semantic-notions.tex' {
            $result = Replace-RegexExact $result `
                '\\item Suppose \$c\$ does not occur in \$!A\$ or \$\\Gamma\$\.' `
                '\item Suppose $!A$ has no free variables other than~$x$, and $c$ does not occur in $!A$ or $\Gamma$.' 1 `
                'semantic-notions/free-variable-premise'
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

$commitType = @(& git -C $repoRoot cat-file -t $expectedCommit 2>$null)
Assert-Exact (($LASTEXITCODE -eq 0) -and $commitType.Count -eq 1 -and $commitType[0] -ceq 'commit') `
    'frozen-source-commit-object' $expectedCommit
Assert-Exact (Test-Path -LiteralPath $manifestPath) 'closure-manifest-present' $manifestPath

$manifest = Import-Csv -LiteralPath $manifestPath
$manifestBatch = @($manifest | Where-Object {
    [int]$_.stable_order -ge 159 -and [int]$_.stable_order -le 166
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
        [int]$row.stable_order -eq (159 + $unitIndex) -and
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
    Assert-Exact ($sourceFileIds.Count -eq $targetFileIds.Count) `
        "$($unit.Id)/localized-file-ids" "count=$($targetFileIds.Count)"
    $totals.localized_file_ids += $targetFileIds.Count

    $sourceChapterIds = @([regex]::Matches($source, '\\olchapter(?:\[[^\]]+\])?'))
    $targetChapterIds = @([regex]::Matches($target, '\\olchapter(?!\[)'))
    Assert-Exact ($sourceChapterIds.Count -eq $targetChapterIds.Count) `
        "$($unit.Id)/chapter-ids" "count=$($targetChapterIds.Count)"
    $totals.chapter_ids += $targetChapterIds.Count

    $sourceDigestRecords.Add("$($unit.Id)|$($unit.SourceBlob)|$($unit.SourceHash)|$sourceRelative")
    $targetDigestRecords.Add("$($unit.Id)|$($unit.TargetHash)|$targetRelative")
}

# Exact source-to-target correction ledger. These are the only admitted
# semantic/structural divergences from the frozen English authority.
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/syntax-and-semantics/intro-semantics.tex' `
    'intro-semantics/n-ary-functions-are-domain-operations' `
    '!!\{function\}s are assigned\s+functions from the !!\{domain\} to itself' 1 `
    '!!\{function\}s diberi\s+operasi-operasi pada !!\{domain\}' 1 1
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/syntax-and-semantics/structures.tex' `
    'structures/single-two-place-hyphen' 'single-two place relation' 1 'satu relasi dua-tempat' 1 1
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/syntax-and-semantics/covered-structures.tex' `
    'covered-structures/consecutive-equals' `
    '\\Value\{\\times\(\\Obj\{two\}, \+\(\\Obj\{three\},\\Obj\{zero\}\)\)\}\{M\} =\\\\' 1 `
    '\\Value\{\\times\(\\Obj\{two\}, \+\(\\Obj\{three\},\\Obj\{zero\}\)\)\}\{M\}\s+\\\\' 1 1
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/syntax-and-semantics/satisfaction.tex' `
    'satisfaction/basic-notions-plural' 'The basic notion that relates' 1 `
    'Gagasan-gagasan dasar yang menghubungkan' 1 1
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/syntax-and-semantics/satisfaction.tex' `
    'satisfaction/quantified-subformula-may-have-free-variable' `
    'immediate !!\{subformula\} of a quantified !!\{formula\} has a free' 1 `
    '!!\{subformula\} langsung dari suatu\s+!!\{formula\} berkuantor dapat mempunyai !!\{variable\} bebas' 1 1
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/syntax-and-semantics/satisfaction.tex' `
    'satisfaction/structure-versus-assignment-subjects' `
    '!!\^a\{structure\} assigns !!a\{value\} to each !!\{constant\}, and a\s+variable assignment to each variable' 1 `
    '!!\^a\{structure\} menetapkan !!a\{value\} kepada setiap !!\{constant\}, dan\s+penugasan variabel menetapkan nilai kepada setiap variabel' 1 1
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/syntax-and-semantics/satisfaction.tex' `
    'satisfaction/omitted-existential-instance' `
    '\\iftag\{prvEx\}\{for at least one \$m \\in\s+\\Domain\{M\}\$\}\{for all' 1 `
    '\\iftag\{prvEx\}\{bagi setidaknya satu\s+\$m \\in \\Domain\{M\}\$, \$\\Sat\{M\}\{!B\(m\)\}\$\}\{bagi semua' 1 1
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/syntax-and-semantics/satisfaction.tex' `
    'satisfaction/relation-has-no-assignment-argument' `
    '\\tuple\{1, 3\} \\notin \\Assign\{R\}\{M\}\[s\]' 1 `
    '\\tuple\{1, 3\} \\notin \\Assign\{R\}\{M\}\$\.' 1 1
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/syntax-and-semantics/satisfaction.tex' `
    'satisfaction/defEx-parentheses-and-comma' `
    '\\Sat/\{M\}\{\\lforall\[x\]\[\\lnot\(\(R\(b,x\) \\lor R\(x,b\)\)\]\}\[s\]|\\Sat\{M\}\{\\lnot\\lforall\[x\]\[\\lnot\(\(R\(b,x\) \\lor\s+R\(x,b\)\)\]\}\[s\]|\\Sat/\{M\}\{\\lexists\[x\]\[\(R\(b,x\) \\land R\(x,b\)\)\]\,\}\[s\]' 3 `
    '\\Sat/\{M\}\{\\lforall\[x\]\[\\lnot\(R\(b,x\) \\lor R\(x,b\)\)\]\}\[s\]|\\Sat\{M\}\{\\lnot\\lforall\[x\]\[\\lnot\(R\(b,x\) \\lor\s+R\(x,b\)\)\]\}\[s\]' 2 3
Assert-RegexCount 'correction-target/satisfaction/defEx-stray-comma-absent' `
    $rawTarget['content/first-order-logic/syntax-and-semantics/satisfaction.tex'] `
    '\\Sat/\{M\}\{\\lexists\[x\]\[\(R\(b,x\) \\land R\(x,b\)\)\]\,\}\[s\]' 0
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/syntax-and-semantics/satisfaction.tex' `
    'satisfaction/defAll-antecedent' `
    '\\Sat/\{M\}\{R\(a,x\)\}\[\\Subst\{s\}\{m\}\{x\}\]\$ for \$m = 2\$, \$3\$, or~\$4\$' 1 `
    '\\Sat/\{M\}\{R\(x,a\)\}\[\\Subst\{s\}\{m\}\{x\}\]\$ untuk \$m = 2\$, \$3\$, atau~\$4\$' 1 1
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/syntax-and-semantics/satisfaction.tex' `
    'satisfaction/missing-m-before-two' 'only \$m = 1\$\s+and \$ = 2\$' 1 `
    'hanya untuk \$m = 1\$ dan\s+\$m = 2\$' 1 1
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/syntax-and-semantics/satisfaction.tex' `
    'satisfaction/outer-variable-m' 'So, for all \$n \\in \\Domain M\$, either' 1 `
    'Jadi, bagi semua \$m \\in \\Domain M\$, berlaku' 1 1
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/syntax-and-semantics/satisfaction.tex' `
    'satisfaction/valid-witness-split' 'namely \$n = 4\$, so that' 1 `
    '\$n = 4\$ ketika \$m = 1\$, dan \$n = 1\$ ketika\s+\$m = 2\$' 1 1
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/syntax-and-semantics/assignments.tex' `
    'assignments/Indonesian-subformula-token' 'sub-!!\{formula\}s' 1 '!!\{subformula\}s' 1 1
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/syntax-and-semantics/assignments.tex' `
    'assignments/tuple-first-index' `
    '\\langle \\Value\{t_i\}\{M\}\[s_2\], \\ldots, \\Value\{t_k\}\{M\}\[s_2\] \\rangle' 1 `
    '\\langle \\Value\{t_1\}\{M\}\[s_2\], \\ldots,\s+\\Value\{t_k\}\{M\}\[s_2\] \\rangle' 1 1
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/syntax-and-semantics/assignments.tex' `
    'assignments/universal-variant-bases' `
    '\$s_1'' = \\Subst\{s\}\{m\}\{x\}\$ and \$s_2'' =\s+\\Subst\{s\}\{m\}\{x\}\$' 1 `
    '\$s_1'' = \\Subst\{s_1\}\{m\}\{x\}\$ serta \$s_2'' =\s+\\Subst\{s_2\}\{m\}\{x\}\$' 1 2
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/syntax-and-semantics/assignments.tex' `
    'assignments/duplicate-Gamma' 'set of !!\{sentence\}s~\$\\Gamma\$' 1 `
    'himpunan !!\{sentence\}s, kita mengatakan' 1 1
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/syntax-and-semantics/extensionality.tex' `
    'extensionality/section-metadata' '(?m)^% Section: substitution$' 1 '(?m)^% Subbagian: extensionality$' 1 1
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/syntax-and-semantics/extensionality.tex' `
    'extensionality/domain-not-domain-size' 'the size of the\s+!!\{domain\}' 1 `
    'ialah !!\{domain\} itu sendiri' 1 1
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/syntax-and-semantics/extensionality.tex' `
    'extensionality/restrict-term-claim' 'for every term,\s+\$\\Value\{t\}\{M_1\}\[s\]' 1 `
    'bagi setiap suku yang\s+muncul dalam~\$!A\$,\s+\$\\Value\{t\}\{M_1\}\[s\]' 1 1
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/syntax-and-semantics/extensionality.tex' `
    'extensionality/consecutive-equals' `
    '\\Value\{\\Subst\{t\}\{t''\}\{x\}\}\{M\}\[s\]\s+= \\\\' 1 `
    '\\Value\{\\Subst\{t\}\{t''\}\{x\}\}\{M\}\[s\]\s+\\\\' 1 1
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/syntax-and-semantics/extensionality.tex' `
    'extensionality/free-for-premise' '\$t''\$~a term, and \$s\$~a variable' 1 `
    '\$t''\$~suatu suku yang !!\{free for\}~\$x\$\s+dalam~\$!A\$, dan \$s\$~suatu' 1 1
Assert-CorrectionClass $rawSource $rawTarget 'content/first-order-logic/syntax-and-semantics/semantic-notions.tex' `
    'semantic-notions/free-variable-premise' `
    '\\item Suppose \$c\$ does not occur in \$!A\$ or \$\\Gamma\$\.' 1 `
    '\\item Andaikan \$!A\$ tidak mempunyai variabel bebas selain~\$x\$, dan \$c\$ tidak\s+muncul dalam \$!A\$ atau \$\\Gamma\$\.' 1 1

# The independent target review corrected a translation of exclusive
# alternatives without changing the frozen English source or math skeleton.
Assert-RegexCount 'target-review/assignments-exclusive-alternatives' `
    $rawTarget['content/first-order-logic/syntax-and-semantics/assignments.tex'] `
    '\$\\Sat\{M\}\{!B\}\[s_[12]\]\$ dan \$\\Sat\{M\}\{!C\}\[s_[12]\]\$, atau' 2
Assert-RegexCount 'target-review/assignments-no-conjunctive-baik-maupun' `
    $rawTarget['content/first-order-logic/syntax-and-semantics/assignments.tex'] `
    'baik\s+\$\\Sat\{M\}\{!B\}\[s_[12]\]\$' 0
$targetReviewAssertions = 1

$allTarget = ($units | ForEach-Object { $rawTarget[$_.Path] }) -join "`n"
Assert-Exact (-not [regex]::IsMatch($allTarget, '\\olfileid(?!\[id\])')) `
    'batch/all-file-identifiers-id'
Assert-Exact (-not [regex]::IsMatch($rawTarget['content/first-order-logic/syntax-and-semantics/semantics.tex'], '\\olchapter\[id\]')) `
    'batch/chapter-command-not-locale-overloaded'

$englishPhrases = @(
    'Giving the meaning of expressions',
    'First-order languages are',
    'Recall that a term',
    'Variable Assignment',
    'In other words',
    'To determine if',
    'For a more complicated case',
    'By induction on',
    'Complete the proof',
    'For the forward direction',
    'For the reverse direction',
    'This problem shows',
    'Semantic Deduction Theorem',
    'Exercise.',
    'Show that',
    'Suppose that'
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

Assert-Exact ($normalizationMatches -eq 18) 'batch/structural-normalization-match-count' 'count=18'
Assert-Exact ($sourceCorrectionClasses -eq 23) 'batch/source-correction-class-count' 'count=23'
Assert-Exact ($sourceCorrectionOccurrences -eq 26) 'batch/source-correction-occurrence-count' 'count=26'
Assert-Exact ($targetCorrectionAssertions -eq 23) 'batch/target-correction-assertion-count' 'count=23'
Assert-Exact ($targetReviewAssertions -eq 1) 'batch/target-review-assertion-count' 'count=1'

# Filled after the first successful exact replay. These totals make parser
# weakening or symmetric source/target omissions fail rather than self-pass.
$expectedTotals = [ordered]@{
    commands = 1894
    environments = 216
    semantic_tokens = 246
    labels = 17
    references = 22
    citations = 0
    assets = 0
    imports = 7
    tagged_items = 37
    tag_conditionals = 23
    math_skeletons = 901
    math_environments = 10
    localized_file_ids = 7
    chapter_ids = 1
}
foreach ($entry in $expectedTotals.GetEnumerator()) {
    Assert-Exact ($totals[$entry.Key] -eq $entry.Value) `
        "batch/frozen-total-$($entry.Key)" "count=$($entry.Value) actual=$($totals[$entry.Key])"
}

$sourceSetDigest = Get-TextDigest @($sourceDigestRecords)
$targetSetDigest = Get-TextDigest @($targetDigestRecords)
foreach ($unit in $units) { Write-Output "TARGET_HASH $($unit.Id) $($unit.Path) $($unit.TargetHash)" }
Write-Output ("STRUCTURAL_TOTALS commands={0} environments={1} semantic_tokens={2} labels={3} references={4} citations={5} assets={6} imports={7} tagged_items={8} tag_conditionals={9} math_skeletons={10} math_environments={11} localized_file_ids={12} chapter_ids={13}" -f `
    $totals.commands, $totals.environments, $totals.semantic_tokens, $totals.labels,
    $totals.references, $totals.citations, $totals.assets, $totals.imports,
    $totals.tagged_items, $totals.tag_conditionals, $totals.math_skeletons,
    $totals.math_environments, $totals.localized_file_ids, $totals.chapter_ids)
Write-Output "CORRECTION_TOTALS source_classes=$sourceCorrectionClasses source_occurrences=$sourceCorrectionOccurrences structural_normalizations=$normalizationMatches target_assertions=$targetCorrectionAssertions target_review_assertions=$targetReviewAssertions"
Write-Output "BINDING_DIGESTS source_set_sha256=$sourceSetDigest target_set_sha256=$targetSetDigest"
Write-Output "FOL_SEMANTICS_BATCH_REPLAY_OK files=$($units.Count) checks=$checks upstream=$expectedCommit closure=OLP-0159..OLP-0166"
