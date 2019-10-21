function Find-NugetPackageInstallationFolder {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string]$Package,
        [string]$Version,
        [ValidateSet("NuGetFallbackFolder", "GlobalPackagesFolder", "HttpCache", "TempCache", "PlugindCache")]
        [string[]]$Locations = @("NuGetFallbackFolder", "GlobalPackagesFolder", "HttpCache", "TempCache", "PlugindCache")
    )
    
    begin {
        $folders=@(Get-NugetInstallationFolder)
    }
    
    process {
        $folders | ForEach-Object {
            if ((Test-Path "$_\$package\$version")) {
                $_
            }
        } | Select-Object -First 1
}
    
end {
}
}