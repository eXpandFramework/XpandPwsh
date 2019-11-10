
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
        $paketExe=(Get-PaketPath $path)
        if ($paketExe){
            $forceArgs = @();
            if ($Force) {
                $forceArgs = "--no-install", "--no-resolve"
            }
            $add=($ProjectPath -and !(Invoke-PaketShowInstalled $ProjectPath)|Where-Object{$_.Include -eq $id} )
            if ($add){
                & $paketExe add $Id --project $ProjectPath --version $Version @forceArgs
            }
            else{
                $depFile="$((Get-Item $paketExe).DirectoryName)\..\paket.dependencies"
                $dependecies=Get-content $depFile -Raw
                $regex = [regex] "(nuget $Id) (.*)"
                $result = $regex.Replace($dependecies, "`$1 $Version")
                Set-Content $depFile $result.Trim()
            }
        }
    }
    
    end {
        
    }
}