function Update-ProjectProperty {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [xml]$CSProj,
        [parameter(Mandatory)]
        [string]$PropertyName,
        [parameter(Mandatory)]
        [string]$Value
    )
    
    begin {
    }
    
    process {
        $CSProj.Project.PropertyGroup | ForEach-Object {
            $property = $_.ChildNodes | Where-Object { $_.Name -eq $PropertyName }
            if (!$property) {
                $property = $_.AppendChild($_.OwnerDocument.CreateElement($PropertyName, $CSProj.DocumentElement.NamespaceURI))
            }
            $property|ForEach-Object{
                $_.InnerText = $Value
            }
        }
    }
    
    end {
    }
}