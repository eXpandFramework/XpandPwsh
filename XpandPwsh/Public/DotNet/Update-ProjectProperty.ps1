function Update-ProjectProperty {
    [CmdletBinding()]
    [CmdLetTag("#visualstudio")]
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
        $node=$CSProj.Project.PropertyGroup.ChildNodes|Where-Object { $_.Name -eq $PropertyName }
        if (!$node){
            Add-XmlElement $CSProj $PropertyName "PropertyGroup" @{} $Value
        }
        else{
            $node|ForEach-Object{
                $_.InnerText=$Value
            }
        }
    }
    
    end {
    }
}