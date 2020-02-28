function Add-NuspecDependency {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
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
        $attributes = [ordered]@{
            id = $id
            version = $version
        }
        Add-XmlElement $Nuspec "dependency" "dependencies" $attributes 
    }
    
    end {
        
    }
}
