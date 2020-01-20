function Add-ProjectReference {
    [CmdletBinding()]
    param (
        [parameter()]
        [System.Xml.XmlDocument]$Owner,
        [parameter(Mandatory)]
        [string]$Include,
        [string]$HintPath,
        [switch]$SpecificVersion
        
    )
    
    begin {
        
    }
    
    process {
        Add-XmlElement $Owner "ItemGroup" "Reference"  ([ordered]@{
            Include    = $Include
        })
    }
    
    end {
        
    }
}