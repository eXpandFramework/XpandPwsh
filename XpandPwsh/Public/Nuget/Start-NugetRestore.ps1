function Start-NugetRestore {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    [alias("sxnr")]
    param (
        [parameter()]
        [string[]]$Source=(Get-PackageSource).Name,
        [parameter(ValueFromPipeline)]
        [string]$Path="."

    )
    
    begin {
        $nuget=Get-NugetPath
        $Source=ConvertTo-PackageSourceLocation $Source
    }
    
    process {
        $item=Get-Item $Path
        $project=$item
        if ($item -is [System.IO.DirectoryInfo]){
            $project=Get-ChildItem $item.FullName -File|Where-Object{
                $_.Name -like "*.*proj" -or $_.Name -like "*.sln"
            }|Select-Object -First 1
        }
        Use-NugetConfig -Path $Path -Sources $Source -ScriptBlock {
            $project|ForEach-Object{& $nuget restore $_.FullName  }
        }
    }
    
    end {
        
    }
}
