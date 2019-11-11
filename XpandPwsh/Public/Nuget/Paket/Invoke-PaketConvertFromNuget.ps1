
function Invoke-PaketConvertFromNuget {
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
                $xtraArgs += "--force"
            }
            Set-Location (Get-Item $paketExe).DirectoryName
            dotnet paket convert-from-nuget @xtraArgs
        }
    }
    
    end {
        
    }
}