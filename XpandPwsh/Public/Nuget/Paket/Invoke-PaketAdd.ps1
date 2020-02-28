
function Invoke-PaketAdd {
    [CmdletBinding()]
    [CmdLetTag(("#nuget","#paket"))]
    param (
        [parameter(Mandatory)]
        [string]$Id,
        [parameter(Mandatory)]
        [string]$Version,
        [string]$ProjectPath,
        [switch]$Force
    )
    
    begin {
        
    }
    
    process {
        $paketExe=(Get-PaketDependenciesPath -Strict)
        if ($paketExe){
            $forceArgs = @();
            if ($Force) {
                $forceArgs = "--no-install", "--no-resolve"
            }
            $add=($ProjectPath -and !(Invoke-PaketShowInstalled $ProjectPath)|Where-Object{$_.Include -eq $id} )
            Push-Location (Get-Item $paketExe).DirectoryName
            if ($add){
                invoke-script {dotnet paket add $Id --project $ProjectPath --version $Version @forceArgs}
            }
            else{
                $depFile="$((Get-Item $paketExe).DirectoryName)\..\paket.dependencies"
                $dependecies=Get-content $depFile -Raw
                $regex = [regex] "(nuget $Id) (.*)"
                $result = $regex.Replace($dependecies, "`$1 $Version")
                Set-Content $depFile $result.Trim()
            }
            Pop-Location
        }
    }
    
    end {
        
    }
}