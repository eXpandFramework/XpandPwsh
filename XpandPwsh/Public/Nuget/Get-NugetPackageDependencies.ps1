function Get-NugetPackageDependencies {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string]$Id,
        [string]$Version,
        [switch]$AllVersions,
        [string]$Source=(get-feed -Nuget)
    )
    
    begin {
        
    }
    
    process {
        $a=@{
            Name=$Id
            Source=$Source
            # Versions=$Version
            AllVersions=$AllVersions
        }
        (Get-NugetPackageSearchMetadata @a).DependencySets.Packages
    }
    
    end {
        
    }
}