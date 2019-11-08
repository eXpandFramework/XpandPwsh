
function Invoke-PaketConvertFromNuget {
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
                $xtraArgs += "--force"
            }
            & $paketExe convert-from-nuget @xtraArgs
        }
    }
    
    end {
        
    }
}