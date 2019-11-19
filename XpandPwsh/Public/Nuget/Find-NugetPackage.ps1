function Find-NugetPackage {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [string]$Name,
        [string]$Source=(Get-PackageFeed -Nuget)
    )
    
    begin {
        
    }
    
    process {
        paket find-packages $Name -s --source $Source|ForEach-Object{
            Get-NugetPackageSearchMetadata $_ -Source $Source|Get-NugetPackageMetadataVersion
        }
        
    }
    
    end {
        
    }
}