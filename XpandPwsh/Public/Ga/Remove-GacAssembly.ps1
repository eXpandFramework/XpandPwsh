function Remove-GacAssembly {
	[CmdletBinding(SupportsShouldProcess = $true)]
	[OutputType('System.Reflection.AssemblyName')]
	param
	(
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
		[ValidateNotNullOrEmpty()]
		[ValidateScript( { Test-AssemblyNameFullyQualified $_ } )]
		[System.Reflection.AssemblyName[]] $AssemblyName,

		[Parameter(Position = 1)]
		[ValidateNotNullOrEmpty()]
		[ValidateScript( { Test-GacAssemblyInstallReferenceCanBeUsed $_ } )]
		[XpandPwsh.Cmdlets.Gac.InstallReference] $InstallReference,

		[Switch] $PassThru
	)

	process {
		foreach ($assmName in $AssemblyName) {
			$fullyQualifiedAssemblyName = $assmName.FullyQualifiedName

			if (!$PSCmdLet.ShouldProcess($fullyQualifiedAssemblyName)) {
				continue
			}

			$disp = [XpandPwsh.Cmdlets.Gac.GlobalAssemblyCache]::UninstallAssembly($assmName, $InstallReference) 
        
			switch ($disp) {
				Unknown {
					Write-Error -Message 'Unknown Error' -Category InvalidResult -TargetObject $assmName
				}
				Uninstalled {
					Write-Verbose "Removed $fullyQualifiedAssemblyName from the GAC"
				}
				StillInUse {
					Write-Error -Message 'Still in use. An application is using the assembly.' -Category PermissionDenied -TargetObject $assmName
				}
				AlreadyUninstalled {
					Write-Error -Message 'Already uninstalled. The assembly does not exist in the GAC.' -Category NotInstalled -TargetObject $assmName
				}
				DeletePending {
					Write-Error -Message 'Delete pending' -Category ResourceBusy -TargetObject $assmName
				}
				HasInstallReference {
					Write-Error -Message 'Has install reference. The assembly has not been removed from the GAC because another install reference exists.' -Category PermissionDenied -TargetObject $assmName
				}
				ReferenceNotFound {
					Write-Error -Message 'Reference not found. The reference that is specified is not found in the GAC' -Category ObjectNotFound -TargetObject $assmName
				}
				default {
					Write-Error -Message "Unknown Error: $disp" -Category InvalidResult -TargetObject $assmName
				}
			}

			if ($PassThru) {
				$assmName
			}
		}
	}
}