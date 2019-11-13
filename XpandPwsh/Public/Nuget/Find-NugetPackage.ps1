function Find-NugetPackage {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [string]$Name
    )
    
    begin {
        
    }
    
    process {
        
        $nugetFeed=Get-PackageFeed -Nuget
        
        paket find-packages $Name -s --source $nugetFeed|foreach{
            Get-NugetPackageSearchMetadata $_ -Source $nugetFeed|Get-NugetPackageMetadataVersion
        }
        
    }
    
    end {
        
    }
}