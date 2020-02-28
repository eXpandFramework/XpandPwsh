<#
.SYNOPSIS
    Retrieves DevExpressInstallation folders from Regitry or from $env:DXFolder which should contain subfolders for each version 
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>
function Get-DevExpressPath {
    [CmdletBinding()]
    [CmdLetTag()]
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