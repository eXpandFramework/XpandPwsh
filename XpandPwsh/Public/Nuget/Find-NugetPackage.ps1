function Find-NugetPackage {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [string]$Name,
        [string]$Source=(Get-PackageFeed -Nuget),
        [switch]$AllVersions
    )
    
    begin {
        
    }
    
    process {
        $pakets=paket find-packages $Name -s --source $Source
        if ($AllVersions){
            $pakets=$pakets|Select-Object -First 1
        }
        $pakets|ForEach-Object{
            $a=@{
                Name=$_
                Source=$Source
                AllVersions=$AllVersions
            }
            Get-NugetPackageSearchMetadata @a|Get-NugetPackageMetadataVersion
        }
        
    }
    
    end {
        
    }
}