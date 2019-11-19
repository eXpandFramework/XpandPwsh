function Get-NugetPackageDependencies {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string]$Id,
        [string]$Source=(get-feed -Nuget)
    )
    
    begin {
        
    }
    
    process {
        (Get-NugetPackageSearchMetadata $Id -Source $Source).DependencySets.Packages
    }
    
    end {
        
    }
}