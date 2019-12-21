function Get-PaketFiles {
    [CmdletBinding()]
    param (
        [switch]$Strict   
    )
    
    begin {
        $nugetFolder=Get-NugetInstallationFolder GlobalPackagesFolder
        "FSharp.Core.dll","Paket.Core.dll","Chessie.dll"|ForEach-Object{"$(Get-ChildItem "$nugetFolder\paket" |Select-Object -Last 1)\tools\netcoreapp2.1\any\$_"}|Mount-Assembly|Out-Null
        
    }
    
    process {
        $a = @{
            Strict = $Strict
        }
        Get-PaketDependenciesPath @a|ForEach-Object{
            $files=[Paket.PaketFiles]::LocateFromDirectory($_.DirectoryName)
            [PSCustomObject]@{
                DepsFile=$files.Item1
                LockFile=$files.Item2
            }
        }   
    }
    
    end {
        
    }
}