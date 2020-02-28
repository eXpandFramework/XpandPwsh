function Add-XmlElement {
    [CmdletBinding()]
    [CmdLetTag("#dotnet")]
    param (
        [parameter()]
        [System.Xml.XmlDocument]$Owner,
        [parameter(Mandatory)]
        [string]$ElementName,
        [parameter(Mandatory)]
        [string]$Parent,
        [System.Collections.Specialized.OrderedDictionary]$Attributes
        
    )
    
    begin {
        
    }
    
    process {
        $ns = New-Object System.Xml.XmlNamespaceManager($Owner.NameTable)
        $nsUri=$Owner.DocumentElement.NamespaceURI
        $ns.AddNamespace("ns", $nsUri)
        $element = $Owner.CreateElement($ElementName, $nsUri)
        if ($Attributes){
            $Attributes.Keys | ForEach-Object {
                $element.SetAttribute($_, $Attributes[$_])
            }
        }
        
        $parentNode = $Owner.SelectSingleNode("//ns:$Parent", $ns)
        $parentNode.AppendChild($Owner.CreateTextNode([System.Environment]::NewLine)) | Out-Null
        $parentNode.AppendChild($Owner.CreateTextNode("    ")) | Out-Null
        $parentNode.AppendChild($element) | Out-Null
    }
    
    end {
        
    }
}