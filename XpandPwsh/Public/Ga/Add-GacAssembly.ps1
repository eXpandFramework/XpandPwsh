function Add-GacAssembly {
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'PathSet')]
    [OutputType('System.Reflection.AssemblyName')]
    param
    (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'PathSet')]
        [ValidateNotNullOrEmpty()]
        [string[]] $Path,

        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'LiteralPathSet')]
        [ValidateNotNullOrEmpty()]
        [Alias('PSPath')]
        [string[]] $LiteralPath,

        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-GacAssemblyInstallReferenceCanBeUsed $_ } )]
        [XpandPwsh.Cmdlets.Gac.InstallReference] $InstallReference,

        [Switch] $Force,

        [Switch] $PassThru
    )

    process {
        if ($PsCmdlet.ParameterSetName -eq 'PathSet') {
            $paths = @()
            foreach ($p in $Path) {
                $paths += (Resolve-Path $p).ProviderPath
            }    
        }
        else {
            $paths = (Resolve-Path -LiteralPath $LiteralPath).ProviderPath
        }

        foreach ($p in $paths) {
            if (!$PSCmdLet.ShouldProcess($p)) {
                continue
            }

            [XpandPwsh.Cmdlets.Gac.GlobalAssemblyCache]::InstallAssembly($p, $InstallReference, $Force)
            Write-Verbose "Installed $p into the GAC"

            if ($PassThru) {
                [System.Reflection.AssemblyName]::GetAssemblyName($p)
            }
        }    
    }
}