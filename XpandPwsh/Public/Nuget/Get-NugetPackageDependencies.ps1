function Get-NugetPackageDependencies {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [parameter(Mandatory)]
        [string]$Id,
        [parameter()][string]$Version,
        [parameter()][switch]$AllVersions,
        [parameter()][string[]]$Source = (Get-PackageSource -ProviderName Nuget).Name,
        [parameter()][string]$FilterRegex,
        [parameter()][switch]$Recurse,
        [parameter()][switch]$IncludeDelisted
    )
    
    begin {
        $Source=ConvertTo-PackageSourceLocation $Source
    }
    
    process {
        $packageChecked = @($id)
        $a = @{
            Name            = $Id
            Source          = $Source -join ";"
            AllVersions     = $AllVersions
            IncludeDelisted = $IncludeDelisted
        }
        if ($Version) {
            $a.Add("Version", $Version)
        }
        elseif ($AllVersion) {
            $a.Add("AllVersions", $AllVersions)
        }
        
        $deps = (Get-NugetPackageSearchMetadata @a).DependencySets.Packages | Get-Unique | Where-Object { $_.id -match $FilterRegex }
        $allDeps = @($deps)
        if ($Recurse) {
            while ($deps) {
                $deps = @($deps | ForEach-Object {
                    if ($_.id -notin $packageChecked) {
                        $a.Name = $_.Id
                        (Get-NugetPackageSearchMetadata @a).DependencySets.Packages | Get-Unique | Where-Object { $_.id -match $FilterRegex }
                        $packageChecked += $a.Name
                    }
                    
                })
                $allDeps += $deps
            }
        }
        
        $allDeps | Sort-Object Id -Unique
    }
    
    end {
        
    }
}