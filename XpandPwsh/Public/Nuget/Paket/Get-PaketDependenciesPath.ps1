function Get-PaketDependenciesPath {
    [CmdletBinding()]
    [CmdLetTag(("#nuget","#paket"))]
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
            [System.IO.FileInfo[]]$items=Get-ChildItem $item.DirectoryName paket.dependencies -Recurse|Where-Object{
                $_.Length -gt 0 -and (Get-ChildItem $_.DirectoryName|Where-Object{ $_ -is [System.IO.DirectoryInfo] -and (Get-ChildItem $_.FullName)})
            }
            $items
        }
        else {
            $item
        }
    }
    
    end {
        
    }
}