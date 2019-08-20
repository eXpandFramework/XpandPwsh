function Get-DevExpressPath {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)]
        [string]$version        
    )
    
    begin {
    }
    
    process {

        
        push-Location 'hklm:\SOFTWARE\WOW6432Node\DevExpress\Components\'
        Get-ChildItem | Where-Object {
            $name = ($_.Name.Split("\") | Select-Object -Last 1)
            if ($version){
                $name -match $version
            }
            else{
                $name
            }
        }|ForEach-Object{
            [PSCustomObject]@{
                Name = ($_.Name.Split("\") | Select-Object -Last 1).Replace("v","")
                Directory=$_.GetValue("RootDirectory")
            }
        }
        Pop-Location
    }
    
    end {
    }
}