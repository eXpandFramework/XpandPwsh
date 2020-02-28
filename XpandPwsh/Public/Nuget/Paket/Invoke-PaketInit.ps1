
function Invoke-PaketInit {
    [CmdletBinding()]
    [CmdLetTag(("#nuget","#paket"))]
    param (
        [switch]$Force,
        [string]$Path = "."
    )
    
    begin {
        
    }
    
    process {
        $paketExe=(Get-PaketDependenciesPath -Strict)
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