
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
        $paketExe=(Get-PaketDependenciesPath $path)
        if ($paketExe){
            $xtraArgs = @();
            if ($Force) {
                $xtraArgs = "--Force"
            }
            Set-Location (Get-Item $paketExe).DirectoryName
            dotnet paket find-refs $Id @xtraArgs
        }
    }
    
    end {
        
    }
}