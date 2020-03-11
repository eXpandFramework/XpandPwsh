function Get-GacAssemblyFile {
    [CmdletBinding()]
    [OutputType('System.IO.FileInfo')]
    param
    (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-AssemblyNameFullyQualified $_ } )]
        [System.Reflection.AssemblyName[]] $AssemblyName
    )

    process {
        foreach ($assmName in $AssemblyName) {
            $path = [XpandPwsh.Cmdlets.Gac.GlobalAssemblyCache]::GetAssemblyPath($assmName)
            [System.IO.FileInfo] $path
        }
    }
}