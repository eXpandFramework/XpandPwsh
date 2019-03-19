using namespace System.Net

$exclude=@("Install-Module.ps1")
Get-ChildItem -Path $PSScriptRoot\public\*.ps1 -Exclude $exclude -Recurse  |ForEach-Object {. $_.FullName}


