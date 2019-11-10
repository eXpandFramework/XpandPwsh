
function Invoke-PaketInit {
    [CmdletBinding()]
    param (
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
            & $paketExe init @xtraArgs
        }
    }
    
    end {
        
    }
}