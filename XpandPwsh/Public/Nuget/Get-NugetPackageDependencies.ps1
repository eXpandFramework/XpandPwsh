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
            AllVersions=$AllVersions
        }
        if ($Version){
            $a.Add("Version",$Version)
        }
        elseif ($AllVersion){
            $a.Add("AllVersions",$AllVersions)
        }
        (Get-NugetPackageSearchMetadata @a).DependencySets.Packages
    }
    
    end {
        
    }
}