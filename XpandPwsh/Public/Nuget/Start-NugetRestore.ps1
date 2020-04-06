function Start-NugetRestore {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    [alias("sxnr")]
    param (
        [ArgumentCompleter({
            [OutputType([System.Management.Automation.CompletionResult])]  # zero to many
            param(
                [string] $CommandName,
                [string] $ParameterName,
                [string] $WordToComplete,
                [System.Management.Automation.Language.CommandAst] $CommandAst,
                [System.Collections.IDictionary] $FakeBoundParameters
            )
            
            (Get-PackageSource).Name|where-object{$_ -match $WordToComplete}
        })]
        [parameter()]
        [string[]]$Sources=(Get-PackageSource).Name,
        [parameter(ValueFromPipeline)]
        [string]$Path="."

    )
    
    begin {
        $nuget=Get-NugetPath
        $sources=Get-PackageSource|Where-Object{$_.Name -in $Sources}|ForEach-Object{$_.Location}|Sort-Object -Unique
    }
    
    process {
        $item=Get-Item $Path
        $project=$item
        if ($item -is [System.IO.DirectoryInfo]){
            $project=Get-ChildItem $item.FullName -File|Where-Object{
                $_.Name -like "*.*proj" -or $_.Name -like "*.sln"
            }|Select-Object -First 1
        }
        Use-NugetConfig -Path $Path -Sources $Sources -ScriptBlock {
            $project|ForEach-Object{& $nuget restore $_.FullName  }
        }
    }
    
    end {
        
    }
}
