
function Invoke-PaketInit {
    [CmdletBinding()]
    param (
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
            dotnet paket init @xtraArgs
        }
    }
    
    end {
        
    }
}