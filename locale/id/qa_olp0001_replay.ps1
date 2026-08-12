$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$localeRoot = $PSScriptRoot
$repoRoot = [IO.Path]::GetFullPath((Join-Path $localeRoot '..\..'))
$expectedCommit = '9620cc73f9c8e0ad003c514a5d3748f29611c4c0'
& git -C $repoRoot merge-base --is-ancestor $expectedCommit HEAD
if ($LASTEXITCODE -ne 0) {
    throw "Authority mismatch: frozen source commit $expectedCommit is not an ancestor of HEAD"
}

$sourcePath = Join-Path $repoRoot 'content\open-logic-about.tex'
$targetPath = Join-Path $localeRoot 'content\open-logic-about.tex'
$source = [IO.File]::ReadAllText($sourcePath)
$target = [IO.File]::ReadAllText($targetPath)
$checks = 0

function Get-Sequence {
    param([string]$Text, [string]$Pattern, [string]$Group)
    return @([regex]::Matches($Text, $Pattern, [Text.RegularExpressions.RegexOptions]::Singleline) |
        ForEach-Object { $_.Groups[$Group].Value })
}

function Assert-Sequence {
    param([string]$Name, [object[]]$Expected, [object[]]$Actual)
    $expectedArray = @($Expected | Where-Object { $null -ne $_ })
    $actualArray = @($Actual | Where-Object { $null -ne $_ })
    if ($expectedArray.Count -ne $actualArray.Count) {
        throw "$Name count mismatch: source=$($expectedArray.Count), target=$($actualArray.Count)"
    }
    for ($index = 0; $index -lt $expectedArray.Count; $index++) {
        if ([string]$expectedArray[$index] -cne [string]$actualArray[$index]) {
            throw "$Name sequence mismatch at index ${index}: source='$($expectedArray[$index])', target='$($actualArray[$index])'"
        }
    }
    $script:checks++
    "PASS $Name count=$($expectedArray.Count)"
}

function Get-BraceBalance {
    param([string]$Text)
    $balance = 0
    for ($index = 0; $index -lt $Text.Length; $index++) {
        if ($Text[$index] -eq '{' -and ($index -eq 0 -or $Text[$index - 1] -ne '\')) { $balance++ }
        if ($Text[$index] -eq '}' -and ($index -eq 0 -or $Text[$index - 1] -ne '\')) { $balance-- }
        if ($balance -lt 0) { return $balance }
    }
    return $balance
}

Assert-Sequence 'commands' `
    (Get-Sequence $source '\\(?<value>[A-Za-z@]+)\*?' 'value') `
    (Get-Sequence $target '\\(?<value>[A-Za-z@]+)\*?' 'value')

Assert-Sequence 'environments' `
    (Get-Sequence $source '\\begin\{(?<value>[^{}]+)\}' 'value') `
    (Get-Sequence $target '\\begin\{(?<value>[^{}]+)\}' 'value')

Assert-Sequence 'href-urls' `
    (Get-Sequence $source '\\href\{(?<value>[^{}]+)\}\{' 'value') `
    (Get-Sequence $target '\\href\{(?<value>[^{}]+)\}\{' 'value')

Assert-Sequence 'addcontentsline-routing' `
    (Get-Sequence $source '\\addcontentsline\{(?<value>[^{}]+\}\{[^{}]+)\}\{' 'value') `
    (Get-Sequence $target '\\addcontentsline\{(?<value>[^{}]+\}\{[^{}]+)\}\{' 'value')

$sourceChapterCount = [regex]::Matches($source, '\\chapter\*\{').Count
$targetChapterCount = [regex]::Matches($target, '\\chapter\*\{').Count
if ($sourceChapterCount -ne 1 -or $targetChapterCount -ne 1) {
    throw "Starred chapter invariant failed: source=$sourceChapterCount target=$targetChapterCount"
}
$checks++
"PASS starred-chapter count=1"

$sourceBraceBalance = Get-BraceBalance $source
$targetBraceBalance = Get-BraceBalance $target
if ($sourceBraceBalance -ne 0 -or $targetBraceBalance -ne 0) {
    throw "Brace balance failed: source=$sourceBraceBalance target=$targetBraceBalance"
}
$checks++
"PASS brace-balance source=0 target=0"

$sourceParagraphCount = @($source -split "(?:`r?`n){2,}" | Where-Object { $_.Trim() }).Count
$targetParagraphCount = @($target -split "(?:`r?`n){2,}" | Where-Object { $_.Trim() }).Count
if ($sourceParagraphCount -ne $targetParagraphCount) {
    throw "Paragraph-block count mismatch: source=$sourceParagraphCount target=$targetParagraphCount"
}
$checks++
"PASS paragraph-blocks count=$sourceParagraphCount"

$requiredTerms = @('Proyek Logika Terbuka', 'Teks Logika Terbuka', 'metalogika formal', 'metode formal', 'sumber terbuka', 'Creative Commons Atribusi')
$missingTerms = @($requiredTerms | Where-Object { $target -cnotmatch [regex]::Escape($_) })
if ($missingTerms.Count -ne 0) {
    throw "Required Indonesian semantic anchors missing: $($missingTerms -join ', ')"
}
$checks++
"PASS semantic-anchors count=$($requiredTerms.Count)"

$residualEnglish = @('About the Open Logic Project', 'is an open-source', 'Coverage of some topics', 'The project operates in the spirit')
$residualFound = @($residualEnglish | Where-Object { $target -cmatch [regex]::Escape($_) })
if ($residualFound.Count -ne 0) {
    throw "Residual English prose detected: $($residualFound -join ', ')"
}
$checks++
"PASS residual-English-prose count=0"

"OLP0001_REPLAY_OK files=1 checks=$checks upstream=$expectedCommit"
