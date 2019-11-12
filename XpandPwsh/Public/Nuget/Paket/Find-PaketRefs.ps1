
function Find-PaketRefs {
    [CmdletBinding()]
    param (
        [string]$Id,
        [switch]$Force,
        [string]$Path = "."
    )
    
    begin {
        
    }
    
    process {
        $paketExe=(Get-PaketDependenciesPath -Strict)
        if ($paketExe){
            $xtraArgs = @();
            if ($Force) {
                $xtraArgs = "--Force"
            }
            dotnet paket find-refs $Id @xtraArgs
        }
    }
    
    end {
        
    }
}