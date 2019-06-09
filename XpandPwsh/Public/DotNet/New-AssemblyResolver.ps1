function New-AssemblyResolver{
    param(
        [parameter(Mandatory)]
        $Path
    )
    . "$PSScriptRoot\..\..\Private\AssemblyResolver.ps1"
    [AssemblyResolver]::new($Path)
}