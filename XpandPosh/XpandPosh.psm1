if (!(Get-module 7Zip4Powershell -ListAvailable)){
    Install-Module 7Zip4Powershell -Scope CurrentUser -Force
}
$nuget="Public\Nuget\nuget.exe"
if (!(Test-Path $nuget)){
    $client.DownloadFile("https://dist.nuget.org/win-x86-commandline/latest/nuget.exe",$nuget)
}
$exclude=@("Install-Module.ps1")
Get-ChildItem -Path $PSScriptRoot\public\*.ps1 -Exclude $exclude  |
ForEach-Object {
    . $_.FullName
}


