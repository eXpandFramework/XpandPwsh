function Get-AssemblyReference{
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [string]$AssemblyPath,
        [string]$NameFilter,
        [string]$VersionFilter
    )
    
    begin {
        Use-MonoCecil|Out-Null
    }
    
    process {
        [Mono.Cecil.AssemblyDefinition]$assembly=[Mono.Cecil.AssemblyDefinition]::ReadAssembly($AssemblyPath)
        $assembly.MainModule.AssemblyReferences|ForEach-Object{
            [PSCustomObject]@{
                Name = $_.Name
                Version = $_.Version.ToString()
                FullName = $_.FullName
            }
        }|Where-Object{
            $nameMatch=!$NameFilter -or $_.Name -like $NameFilter
            $versionMatch=!$VersionFilter -or $_.Version -like $VersionFilter 
            $nameMatch -and $versionMatch

        }
        $assembly.dispose()
    }
    
    end {
        
    }
}