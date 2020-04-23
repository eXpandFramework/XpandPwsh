using namespace System.Net
if (!(Get-module 7Zip4Powershell -ListAvailable)){
    Install-Module 7Zip4Powershell -Scope CurrentUser -Force
    Install-Module powershell-yaml -Scope CurrentUser -Force
}
$psCoreCmdlets=@("Format-Text.ps1")
$exclude=@("Install-Module.ps1")
. $PSScriptRoot\private\attributes.ps1
Get-ChildItem -Path $PSScriptRoot\public\*.ps1 -Exclude ($exclude+$psCoreCmdlets) -Recurse  |ForEach-Object {. $_.FullName}
if ($PSVersionTable.Psedition -eq "Core"){
    Get-ChildItem -Path $PSScriptRoot\public -Include $psCoreCmdlets -Exclude $exclude -Recurse  |ForEach-Object {. $_.FullName}
}
$global:XpandPwshPath=$PSScriptRoot
. $PSScriptRoot\private\Completers\RegisterCompleter.ps1


