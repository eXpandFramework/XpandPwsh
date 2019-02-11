$exclude=@("SourcePack.ps1","Install-Module.ps1")
Get-ChildItem -Path $PSScriptRoot\public\*.ps1 -Exclude $exclude  |
ForEach-Object {
    . $_.FullName
}
