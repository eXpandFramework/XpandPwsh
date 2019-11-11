function Get-PaketDependenciesPath {
    [CmdletBinding()]
    param (
        [string]$Path="."
    )
    
    begin {
        
    }
    
    process {
        $paketDirectoryInfo = (Get-Item $Path).Directory
        if (!$paketDirectoryInfo){
            $paketDirectoryInfo = Get-Item $Path
        }
        $paketDependeciesFile = "$($paketDirectoryInfo.FullName)\paket.dependencies"
        while (!(Test-Path $paketDependeciesFile)) {
            $paketDirectoryInfo = $paketDirectoryInfo.Parent
            if (!$paketDirectoryInfo){
                return
            }
            $paketDependeciesFile = "$($paketDirectoryInfo.FullName)\paket.dependencies"
        }
        $item=Get-Item $paketDependeciesFile
        Set-Location $item.Directory.Parent.FullName
        $item
    }
    
    end {
        
    }
}