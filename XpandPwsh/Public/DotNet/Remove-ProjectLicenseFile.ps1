function Remove-ProjectLicenseFile {
    [CmdletBinding()]
    [CmdLetTag("#visualstudio")]
    param (
        [parameter()]
        [xml]$CSProj,
        [string]$FilePath
    )
    
    begin {
    }
    
    process {
        if ($FilePath){
            [xml]$CSProj=Get-XmlContent $FilePath
        }
        $CSProj.Project.ItemGroup.EmbeddedResource | ForEach-Object {
            if ($_.Include -eq "Properties\licenses.licx") {
                $_.parentnode.RemoveChild($_) 
            }
        }
        if ($FilePath){
            $CSProj|Save-Xml $FilePath|Out-Null
        }
    }
    
    end {
    }
}