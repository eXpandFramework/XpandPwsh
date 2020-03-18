function Add-XmlElement {
    [CmdletBinding(DefaultParameterSetName="Parent")]
    [CmdLetTag("#dotnet")]
    param (
        [parameter(Mandatory)]
        [System.Xml.XmlDocument]$Owner,
        [parameter(Mandatory)]
        [string]$ElementName,
        [parameter(Mandatory,ParameterSetName="Parent")]
        [string]$Parent,
        [System.Collections.Specialized.OrderedDictionary]$Attributes,
        [string]$InnerText,
        [parameter(Mandatory,ParameterSetName="ParentNode")]
        [System.Xml.XmlElement]$ParentNode
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
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
        $element.InnerText=$InnerText;
        if (!$ParentNode){
            $parentNode = $Owner.SelectSingleNode("//ns:$Parent", $ns)
        }
        $parentNode.AppendChild($Owner.CreateTextNode([System.Environment]::NewLine)) | Out-Null
        $parentNode.AppendChild($Owner.CreateTextNode("    ")) | Out-Null
        
        $parentNode.AppendChild($element) | Out-Null
        $element
    }
    
    end {
        
    }
}