function Get-NugetInstallationFolder {
    param(
        [ValidateSet("NuGetFallbackFolder", "GlobalPackagesFolder", "HttpCache", "TempCache", "PlugindCache")]
        [string[]]$Locations = @("NuGetFallbackFolder", "GlobalPackagesFolder", "HttpCache", "TempCache", "PlugindCache")
    )

    [System.Collections.ArrayList]$folders = @()
    if ($Locations -contains "NuGetFallbackFolder") {
        $path = (Get-DotNetCoreVersion | Select-Object -First 1).Path
        $folders.Add("$path\NuGetFallbackFolder") | Out-Null
    }
    if ($Locations -contains "GlobalPackagesFolder") {
        $folders.Add("$env:USERPROFILE\.nuget\packages") | Out-Null
    }
    if ($Locations -contains "HttpCache") {
        $folders.Add("$env:LOCALAPPDATA\Nuget\v3-cache") | Out-Null
    }
    if ($Locations -contains "TempCache") {
        $folders.Add("$env:LOCALAPPDATA\Temp\NugetScratch") | Out-Null
    }
    if ($Locations -contains "PlugindCache") {
        $folders.Add("$env:LOCALAPPDATA\Nuget\plugins-cache") | Out-Null
    }
    $folders
}
