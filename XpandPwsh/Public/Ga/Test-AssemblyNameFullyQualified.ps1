function Test-AssemblyNameFullyQualified {
	[CmdletBinding()]
	[OutputType('System.Boolean')]
	param
	(
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
		[ValidateNotNullOrEmpty()]
		[System.Reflection.AssemblyName[]] $AssemblyName
	)
	
	process {
		foreach ($assmName in $AssemblyName) {
			[XpandPwsh.Cmdlets.Gac.GlobalAssemblyCache]::IsFullyQualifiedAssemblyName($assmName)
		}
	}
}