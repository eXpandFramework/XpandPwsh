
function Invoke-PaketInstall {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)]
        [string]$Path = ".",
        [switch]$Force
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
            dotnet paket install @xtraArgs
        }
    }
    
    end {
        
    }
}