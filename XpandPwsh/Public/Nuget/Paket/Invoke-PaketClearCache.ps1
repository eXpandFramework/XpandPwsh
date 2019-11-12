
function Invoke-PaketClearCache {
    [CmdletBinding()]
    param (
        [switch]$SkipLocal,
        [string]$Path = "."
    )
    
    begin {
        
    }
    
    process {
        $paketExe = (Get-PaketDependenciesPath -Strict)
        if ($paketExe) {
            $commandArgs = @();
            if (!$SkipLocal) {
                $commandArgs = @("--clear-local")
            }
            Set-Location (Get-Item $paketExe).DirectoryName
            dotnet paket clear-cache @commandArgs
        }
    }
    
    end {
        
    }
}