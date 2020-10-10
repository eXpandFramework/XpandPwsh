function Add-NuspecDependency {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        $Id,
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        $Version,
        [parameter(Mandatory)]
        [xml]$Nuspec,
        [string]$TargetFramework

    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin        
    }
    
    process {
        if ($TargetFramework){
            $group=Add-XmlElement -Owner $Nuspec -ElementName "group" -Parent "dependencies" -Attributes ([ordered]@{targetFramework=$TargetFramework})
        }
        $attributes = [ordered]@{
            id = $id
            version = $version
        }
        if (!$group){
            Add-XmlElement -Owner $Nuspec -ElementName "dependency" -Parent "dependencies" -Attributes $attributes  
        }
        else{
            Add-XmlElement -Owner $Nuspec -ElementName "dependency" -ParentNode $group -Attributes $attributes
        }
    }
    
    end {
        
    }
}
