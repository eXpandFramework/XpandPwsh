function Add-ProjectReference {
    [CmdletBinding()]
    [CmdLetTag("#dotnet")]
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
        $nsUri=$Owner.DocumentElement.NamespaceURI
        $r = $Owner.CreateElement("Reference",$nsUri)
        $r.SetAttribute("Include", $Include)
        if ($HintPath){
            $h = $Owner.CreateElement("HintPath",$nsUri)    
            $h.InnerText = $HintPath.Replace("\\","\")
            $r.AppendChild($h)|out-null
        }
        $s = $Owner.CreateElement("SpecificVersion",$nsUri)    
        $s.InnerText = $SpecificVersion.IsPresent.ToString()
        $r.AppendChild($s)|out-null
        $ns = New-Object System.Xml.XmlNamespaceManager($Owner.NameTable)
        $ns.AddNamespace("ns", $nsUri)
        $refNode = $Owner.SelectSingleNode("//ns:Reference", $ns).ParentNode
        if (!$refNode){
            $refNode = $Owner.SelectSingleNode("//ns:ItemGroup", $ns)
        }
        $refNode.AppendChild($r)|out-null
    }
    
    end {
        
    }
}