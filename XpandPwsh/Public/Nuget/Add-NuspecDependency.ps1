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
        $ns = New-Object System.Xml.XmlNamespaceManager($nuspec.NameTable)
        $ns.AddNamespace("ns", $nuspec.DocumentElement.NamespaceURI)
        $dependency = $nuspec.CreateElement("dependency", $nuspec.DocumentElement.NamespaceURI)
        $dependency.SetAttribute("id", $id)
        $dependency.SetAttribute("version", $version)
        $nuspec.SelectSingleNode("//ns:dependencies", $ns).AppendChild($dependency) | Out-Null
    }
    
    end {
        
    }
}