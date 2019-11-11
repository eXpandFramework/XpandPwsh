
function Invoke-PaketFindVersions {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [string]$Id ,
        [int]$Max = 1,
        [string]$Path = ".",
        [switch]$Force
    )
    
    begin {
        
    }
    
    process {
        $paketExe = (Get-PaketDependenciesPath $path)
        if ($paketExe) {
            $xtraArgs = @();
            if ($Max) {
                $xtraArgs += "--max $Max"
            }
            Set-Location (Get-Item $paketExe).DirectoryName
            dotnet paket find-package-versions $Id --max $Max | Select-Object -skip 1 -first $Max
        }
    }
    
    end {
        
    }
}