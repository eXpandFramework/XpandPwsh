
function Invoke-PaketRestore {
    [CmdletBinding()]
    param (
        [switch]$Force,
        [string]$Group,
        [string]$Path="." 
    )
    
    begin {
        
    }
    
    process {
        $paketExe=(Get-PaketPath $path)
        if ($paketExe){
            $xtraArgs = @();
            if ($Force) {
                $xtraArgs += "--Force"
                $xtraArgs += "--group $group"
            }
            & $paketExe restore @xtraArgs
        }
    }
    
    end {
        
    }
}