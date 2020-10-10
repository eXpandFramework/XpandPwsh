function Add-XmlElement {
    [CmdletBinding(DefaultParameterSetName = "Parent")]
    [CmdLetTag("#dotnet")]
    param (
        [parameter(Mandatory, Position = 0)]
        [System.Xml.XmlDocument]$Owner,
        [parameter(Mandatory, Position = 1)]
        [string]$ElementName,
        [parameter(Mandatory, ParameterSetName = "Parent", Position = 2)]
        [string]$Parent,
        [parameter(Position = 3)]
        [System.Collections.Specialized.OrderedDictionary]$Attributes,
        [parameter(Position = 4)]
        [string]$InnerText,
        [parameter(Mandatory, ParameterSetName = "ParentNode", Position = 5)]
        [System.Xml.XmlElement]$ParentNode
    )
    
    begin {
        $PSCmdlet | Write-PSCmdLetBegin
    }
    
    process {
        $ns = New-Object System.Xml.XmlNamespaceManager($Owner.NameTable)
        $nsUri = $Owner.DocumentElement.NamespaceURI
        $ns.AddNamespace("ns", $nsUri)
        if ($Attributes) {
            $attributesFilter="["
            $attributesFilter=$Attributes.Keys | ForEach-Object {
                "@$_='$($Attributes[$_])'"
            } |Join-String -Separator " and "
            $attributesFilter="[$attributesFilter]"
        }
        
        $element = $Owner.SelectSingleNode("//ns:$ElementName$($attributesFilter)", $ns)
        if (($ParentNode -and $element.ParentNode -ne $ParentNode) -or ($Parent -and $element.ParentNode.LocalName -ne $Parent)){
            $element = $Owner.CreateElement($ElementName, $nsUri)
        }
        if ($Attributes) {
            $Attributes.Keys | ForEach-Object {
                $element.SetAttribute($_, $Attributes[$_])
            }
        }
        if ($InnerText){
            $element.InnerText = $InnerText;
        }
        
        if (!$ParentNode) {
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