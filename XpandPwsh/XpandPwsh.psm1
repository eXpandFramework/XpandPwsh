using namespace System.Net
if (!(Get-module 7Zip4Powershell -ListAvailable)){
    Install-Module 7Zip4Powershell -Scope CurrentUser -Force
    Install-Module powershell-yaml -Scope CurrentUser -Force
}

$exclude=@("Install-Module.ps1")
Get-ChildItem -Path $PSScriptRoot\public\*.ps1 -Exclude $exclude -Recurse  |ForEach-Object {. $_.FullName}
$global:XpandPwshPath=(get-item (Get-Module XpandPwsh -ListAvailable).Path).DirectoryName


