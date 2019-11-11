
function Invoke-PaketAdd {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string]$Id,
        [parameter(Mandatory)]
        [string]$Version,
        [string]$ProjectPath,
        [switch]$Force,
        [string]$Path = "."
    )
    
    begin {
        
    }
    
    process {
        $paketExe = (Get-PaketPath $path)
        if ($paketExe) {
            $forceArgs = @();
            if ($Force) {
                $forceArgs = "--no-install", "--no-resolve"
            }
            $add = ($ProjectPath -and !(Invoke-PaketShowInstalled -project $ProjectPath | Where-Object { $_.Id -eq $id } ))
            if ($add) {
                & $paketExe add $Id --project $ProjectPath --version $Version @forceArgs
            }
            else {
                $depFile = "$((Get-Item $paketExe).DirectoryName)\..\paket.dependencies"
                $dependecies = Get-Content $depFile -Raw
                $regex = [regex] "(nuget $Id) (.*)"
                $result = $regex.Replace($dependecies, "`$1 $Version")
                Set-Content $depFile $result.Trim()
                if ($ProjectPath) {
                    $packagesConfig = "$(Get-Item $ProjectPath).DirectoryName\packages.config"
                    if (Test-Path $packagesConfig) {
                        $c = Get-Content $packagesConfig
                        $regex = [regex] '(.*)id="DevExpress(.*)version="([^"]*)'
                        $result = $regex.Replace($c, "`$1id=`"DevExpress`$2version=`"$Version")
                        Set-Content $packagesConfig $result
                    }
                }
            }
        }
    }
    
    end {
        
    }
}