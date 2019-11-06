function Get-PaketPath {
    [CmdletBinding()]
    param (
        [string]$Path="."
    )
    
    begin {
        
    }
    
    process {
        $paketDirectoryInfo = Get-Item $Path
        $paketDependeciesFile = "$($paketDirectoryInfo.FullName)\.paket\paket.exe"
        while (!(Test-Path $paketDependeciesFile)) {
            $paketDirectoryInfo = $paketDirectoryInfo.Parent
            $paketDependeciesFile = "$($paketDirectoryInfo.FullName)\.paket\paket.exe"
        }
        Get-Item $paketDependeciesFile
    }
    
    end {
        
    }
}