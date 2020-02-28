
function Invoke-PaketRemove {
    [CmdletBinding()]
    [CmdLetTag(("#nuget","#paket"))]
    param (
        [parameter(Mandatory)]
        [string]$Id,
        [string]$ProjectPath,
        [switch]$Force,
        [Switch]$Silent
    )
    
    begin {
        
    }
    
    process {
        if (Test-path $ProjectPath){
            Push-Location (get-item $ProjectPath).DirectoryName
        }
        $paketExe=(Get-PaketDependenciesPath -Strict)
        if ($paketExe){
            $a = @();
            if ($Force) {
                $a += "--no-install"
            }
            if ($Silent){
                $a+="--silent"
            }
            invoke-script {dotnet paket remove $Id --project $ProjectPath @a}
            Pop-Location
        }
        if (Test-path $ProjectPath){
            Pop-Location
        }
    }
    
    end {
        
    }
}