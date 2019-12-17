function Add-NuspecDependency {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        $Id,
        [parameter(Mandatory)]
        $Version,
        [parameter(Mandatory)]
        $Nuspec

    )
    
    begin {
        
    }
    
    process {
        $attributes = @{
            version = $version
            id = $id
        }
        Add-XmlElement $Nuspec "dependency" "dependencies" $attributes 
    }
    
    end {
        
    }
}
