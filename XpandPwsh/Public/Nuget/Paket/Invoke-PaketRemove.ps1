
function Invoke-PaketRemove {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string]$Id,
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
            $remove=($ProjectPath -and (Invoke-PaketShowInstalled $ProjectPath)|Where-Object{$_.Include -eq $id} )
            push-Location (Get-Item $paketExe).DirectoryName
            if ($remove){
                invoke-script {dotnet paket remove $Id --project $ProjectPath @forceArgs}
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