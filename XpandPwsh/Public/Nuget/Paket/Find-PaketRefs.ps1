
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
        $paketExe=(Get-PaketPath $path)
        if ($paketExe){
            $xtraArgs = @();
            if ($Force) {
                $xtraArgs = "--Force"
            }
            & $paketExe find-refs $Id @xtraArgs
        }
    }
    
    end {
        
    }
}