function Add-NuspecDependency {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        $Id,
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        $Version,
        [parameter(Mandatory)]
        $Nuspec

    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin        
    }
    
    process {
        $attributes = [ordered]@{
            id = $id
            version = $version
        }
        Add-XmlElement -Owner $Nuspec -ElementName "dependency" -Parent "dependencies" -Attributes $attributes 
    }
    
    end {
        
    }
}
