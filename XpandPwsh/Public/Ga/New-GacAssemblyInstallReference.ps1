function New-GacAssemblyInstallReference {
    [CmdletBinding()]
    [OutputType('XpandPwsh.Cmdlets.Gac.InstallReference')]
    param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [XpandPwsh.Cmdlets.Gac.InstallReferenceType] $Type,

        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Identifier,

        [Parameter(Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string] $Description
    )
	
    process {
        New-Object -TypeName 'XpandPwsh.Cmdlets.Gac.InstallReference' -ArgumentList $Type, $Identifier, $Description
    }
}