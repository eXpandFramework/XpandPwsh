function Add-XmlElement {
    [CmdletBinding(DefaultParameterSetName="Parent")]
    [CmdLetTag("#dotnet")]
    param (
        [parameter(Mandatory,Position=0)]
        [System.Xml.XmlDocument]$Owner,
        [parameter(Mandatory,Position=1)]
        [string]$ElementName,
        [parameter(Mandatory,ParameterSetName="Parent",Position=2)]
        [string]$Parent,
        [parameter(Position=3)]
        [System.Collections.Specialized.OrderedDictionary]$Attributes,
        [parameter(Position=4)]
        [string]$InnerText,
        [parameter(Mandatory,ParameterSetName="ParentNode",Position=5)]
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