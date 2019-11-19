
function Invoke-PaketAdd {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string]$Id,
        [parameter()]
        [string]$Version,
        [System.IO.FileInfo]$ProjectPath,
        [switch]$Force,
        [string]$Path = "."
    )
    
    begin {
        
    }
    
    process {
        $depFile = (Get-PaketDependenciesPath -Strict)
        if ($depFile) {
            $forceArgs = @();
            if ($Force) {
                $forceArgs = "--no-install", "--no-resolve"
            }
            if ($Version){
                $forceArgs+="--version $Version"
            }
            dotnet paket add $Id --project $ProjectPath @forceArgs
            return
            $add = ($ProjectPath -and !(Invoke-PaketShowInstalled -project $ProjectPath | Where-Object { $_.Id -eq $id } ))
            if ($add) {
                
            }
            else {
                throw
                $dependecies = Get-Content $depFile.FullName -Raw
                $regex = [regex] "(nuget $Id) (.*)"
                $result = $regex.Replace($dependecies, "`$1 $Version")
                Set-Content $depFile $result.Trim()
            }
        }
    }
    
    end {
        
    }
}