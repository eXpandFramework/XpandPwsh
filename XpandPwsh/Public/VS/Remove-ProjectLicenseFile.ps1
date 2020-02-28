function Remove-ProjectLicenseFile {
    [CmdletBinding()]
    [CmdLetTag("#visualstudio")]
    param (
        [parameter(Mandatory)]
        [xml]$CSProj
    )
    
    begin {
    }
    
    process {
        $CSProj.Project.ItemGroup.EmbeddedResource | ForEach-Object {
            if ($_.Include -eq "Properties\licenses.licx") {
                $_.parentnode.RemoveChild($_) | out-null
            }
        }
    }
    
    end {
    }
}