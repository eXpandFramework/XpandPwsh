$GitHubUser="eXpandFramework"
Set-Location $PSScriptRoot
$scriptFunctions=Get-childitem "..\XpandPwsh\Public" *.ps1 -Recurse|ForEach-Object{
    $_.BaseName
}
Write-Host "ScriptFunctions:" -f Blue
$scriptFunctions
Import-Module "..\XpandPwsh\Cmdlets\bin\XpandPwsh.Cmdlets.dll"
$exportedCommands=(Get-Module XpandPwsh.Cmdlets).ExportedCommands.Keys
Write-Host "ExportedCommands:" -f Blue
$exportedCommands
$functions=(($scriptFunctions+$exportedCommands)|Sort-Object|ForEach-Object{
    "`"$_`""
}) -join ",`r`n"
$psd1=Get-Content "..\XpandPwsh\XpandPwsh.psd1" -Raw

$regex = [regex] '(?isx)FunctionsToExport\ =\ @\(([^\)]*)\)'
$psd1 = $regex.Replace($psd1, @"
FunctionsToExport = @(
    $functions
)
"@
)

Set-Content "..\XpandPwsh\XpandPwsh.psd1" $psd1.Trim()
$lastSha = Get-GitLastSha "https://github.com/$GitHubUser/XpandPwsh.git"
Write-Host "lastSha=$lastSha" -f Blue
if (git diff --name-only "$lastSha" HEAD|Where-Object{$_ -like "*.psd1"}){
    New-BurntToastNotification -Text "Manifest changed" -Sound 'Alarm2' -ExpirationTime ([datetime]::Now.AddSeconds(5))
    exit 1
}

