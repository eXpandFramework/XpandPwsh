
function Invoke-PaketClearCache {
    [CmdletBinding()]
    param (
        [switch]$SkipLocal,
        [string]$Path = "."
    )
    
    begin {
        
    }
    
    process {
        $paketExe=(Get-PaketPath $path)
        if ($paketExe){
            $commandArgs = @();
            if (!$SkipLocal) {
                $commandArgs = @("--clear-local")
            }
            & $paketExe clear-cache @commandArgs
        }
    }
    
    end {
        
    }
}