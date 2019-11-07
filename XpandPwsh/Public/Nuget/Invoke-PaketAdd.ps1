
function Invoke-PaketAdd {
    [CmdletBinding()]
    param (
        [string]$Path = ".",
        [parameter(Mandatory)]
        [string]$Id,
        [parameter(Mandatory)]
        [string]$Version
    )
    
    begin {
        
    }
    
    process {
        $paketDependeciesFile = "$((Get-PaketPath $path).DirectoryName)\..\paket.dependencies"
        if ($paketDependeciesFile){
            & $paketDependeciesFile add $Id --version $Version --no-install --no-resolve
        }
    }
    
    end {
        
    }
}