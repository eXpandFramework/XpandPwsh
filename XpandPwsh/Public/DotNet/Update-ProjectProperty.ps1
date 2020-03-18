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
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        $node=$CSProj.Project.PropertyGroup.ChildNodes|Where-Object { $_.Name -eq $PropertyName }
        if (!$node){
            Add-XmlElement -Owner $CSProj -ElementName $PropertyName -Parent "PropertyGroup" -InnerText $Value 
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