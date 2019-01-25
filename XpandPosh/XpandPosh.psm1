Get-ChildItem -Path $PSScriptRoot\public\*.ps1 -Exclude SourcePack.ps1  |
ForEach-Object {
    . $_.FullName
}
