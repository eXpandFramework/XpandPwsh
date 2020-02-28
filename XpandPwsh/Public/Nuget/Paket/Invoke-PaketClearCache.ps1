
function Invoke-PaketClearCache {
    [CmdletBinding()]
    [CmdLetTag(("#nuget","#paket"))]
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
            Push-Location (Get-Item $paketExe).DirectoryName
            dotnet paket clear-cache @commandArgs
            Pop-Location
        }
    }
    
    end {
        
    }
}