function Add-NuspecDependency {
    [CmdletBinding()]
    param (
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        $Id,
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        $Version,
        [parameter(Mandatory)]
        $Nuspec

    )
    
    begin {
        
    }
    
    process {
        $attributes = @{
            id = $id
            version = $version
        }
        Add-XmlElement $Nuspec "dependency" "dependencies" $attributes 
    }
    
    end {
        
    }
}
