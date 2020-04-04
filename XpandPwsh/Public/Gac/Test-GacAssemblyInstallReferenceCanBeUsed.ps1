function Test-GacAssemblyInstallReferenceCanBeUsed {
    [CmdletBinding()]
    [OutputType('System.Boolean')]
    param
    (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [XpandPwsh.Cmdlets.Gac.InstallReference[]] $InstallReference
    )
	
    process {
        foreach ($reference in $InstallReference) {
            $reference.CanBeUsed()
        }
    }
}