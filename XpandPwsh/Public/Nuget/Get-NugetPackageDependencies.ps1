function Get-NugetPackageDependencies {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [parameter(Mandatory)]
        [string]$Id,
        [string]$Version,
        [switch]$AllVersions,
        [ArgumentCompleter( {
                [OutputType([System.Management.Automation.CompletionResult])]  # zero to many
                param(
                    [string] $CommandName,
                    [string] $ParameterName,
                    [string] $WordToComplete,
                    [System.Management.Automation.Language.CommandAst] $CommandAst,
                    [System.Collections.IDictionary] $FakeBoundParameters
                )
            
                (Get-PackageSource).Name | Where-Object { $_ -like "$wordToComplete*" }
            })]
        [string]$Source = (Get-PackageFeed -Nuget),
        [string]$FilterRegex,
        [switch]$Recurse,
        [switch]$IncludeDelisted
    )
    
    begin {
        if ($source -in (Get-PackageSource).Name ) {
            $Source = Get-PackageSourceLocations -Name $Source
        }
    }
    
    process {
        $packageChecked = @($id)
        $a = @{
            Name            = $Id
            Source          = $Source
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