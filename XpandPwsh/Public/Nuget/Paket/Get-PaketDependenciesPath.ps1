function Get-PaketDependenciesPath {
    [CmdletBinding()]
    param (
        [switch]$Strict
    )
    
    begin {
        
    }
    
    process {
        $paketDirectoryInfo = Get-Item .
        $paketDependeciesFile = "$($paketDirectoryInfo.FullName)\paket.dependencies"
        while (!(Test-Path $paketDependeciesFile)) {
            $paketDirectoryInfo = $paketDirectoryInfo.Parent
            if (!$paketDirectoryInfo){
                return
            }
            $paketDependeciesFile = "$($paketDirectoryInfo.FullName)\paket.dependencies"
        }
        $item=Get-Item $paketDependeciesFile
        
        if (!$Strict -and $item){
            [System.IO.FileInfo[]]$items=Get-ChildItem $item.DirectoryName paket.dependencies -Recurse
            $items
        }
        else {
            $item
        }
    }
    
    end {
        
    }
}