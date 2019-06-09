$GitHubUser="eXpandFramework"
$scriptFunctions=Get-childitem "..\XpandPwsh\Public" *.ps1 -Recurse|ForEach-Object{
    $_.BaseName
}
Import-Module "..\XpandPwsh\Cmdlets\bin\XpandPwsh.Cmdlets.dll"
$exportedCommands=(Get-Module XpandPwsh.Cmdlets).ExportedCommands.Keys
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
if (git diff --name-only "$lastSha" HEAD|Where-Object{$_ -like "*.psd1"}){
    Write-Error "Manifest changed"
    exit 1
}

