
function Get-NugetInstallationFolder  {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param(
        [ValidateSet("NuGetFallbackFolder", "GlobalPackagesFolder", "HttpCache", "TempCache", "PluginCache")]
        [string[]]$Locations = @("NuGetFallbackFolder", "GlobalPackagesFolder", "HttpCache", "TempCache", "PluginCache")
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin        
    }
    
    process {
        [System.Collections.ArrayList]$folders = @()
        if ($Locations -contains "NuGetFallbackFolder") {
            $path = (Get-DotNetCoreVersion | Select-Object -First 1).Path
            $folders.Add("$path\NuGetFallbackFolder") | Out-Null
        }
        if ($Locations -contains "GlobalPackagesFolder") {
            $packagesFolder=$env:NUGET_PACKAGES
            if (!$packagesFolder){
                $packagesFolder="$env:USERPROFILE\.nuget\packages"    
            }
            $folders.Add($packagesFolder) | Out-Null
        }
        if ($Locations -contains "HttpCache") {
            $folders.Add("$env:LOCALAPPDATA\Nuget\v3-cache") | Out-Null
        }
        if ($Locations -contains "TempCache") {
            $folders.Add("$env:LOCALAPPDATA\Temp\NugetScratch") | Out-Null
        }
        if ($Locations -contains "PluginCache") {
            $folders.Add("$env:LOCALAPPDATA\Nuget\plugins-cache") | Out-Null
        }
        $folders        
    }
    
    end {
        
    }
}

