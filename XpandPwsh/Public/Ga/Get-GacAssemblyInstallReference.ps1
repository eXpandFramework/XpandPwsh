function Get-GacAssemblyInstallReference {
    [CmdletBinding()]
    [OutputType('XpandPwsh.Cmdlets.Gac.InstallReference')]
    param
    (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-AssemblyNameFullyQualified $_ } )]
        [System.Reflection.AssemblyName[]] $AssemblyName
    )

    process {
        foreach ($assmName in $AssemblyName) {
            [XpandPwsh.Cmdlets.Gac.GlobalAssemblyCache]::GetInstallReferences($assmName)
        }
    }
}