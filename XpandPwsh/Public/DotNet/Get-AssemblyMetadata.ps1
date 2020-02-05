function Get-AssemblyMetadata{
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string]$AssemblyPath,
        [string[]]$Key
    )
    
    begin {
        Use-MonoCecil|Out-Null        
    }
    
    process {
        [Mono.Cecil.AssemblyDefinition]$assembly=[Mono.Cecil.AssemblyDefinition]::ReadAssembly($AssemblyPath)
        
        $metadata=$assembly.CustomAttributes | 
            Where-Object { $_.AttributeType -like "System.Reflection.AssemblyMetadataAttribute" } | ForEach-Object { 
                [PSCustomObject]@{
                    Key = $_.ConstructorArguments[0].Value
                    Value =$_.ConstructorArguments[1].Value
                }
        }|Where-Object{
            $mKey=$_.Key
            !$Key -or ($Key|Where-Object{$_ -eq $mKey})
        }
        if (!$Key -and !$metadata){
            throw "$Key metatada not found"
        }
        $metadata
        $assembly.dispose()
    }
    
    end {
        
    }
}