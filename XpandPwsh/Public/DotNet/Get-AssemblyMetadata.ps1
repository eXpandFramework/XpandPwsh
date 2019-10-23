function Get-AssemblyMetadata{
    [CmdletBinding()]
    param (
        [string]$AssemblyPath
    )
    
    begin {
        
    }
    
    process {
        [Mono.Cecil.AssemblyDefinition]$assembly=[Mono.Cecil.AssemblyDefinition]::ReadAssembly($AssemblyPath)
        
        $assembly.CustomAttributes | 
            Where-Object { $_.AttributeType -like "System.Reflection.AssemblyMetadataAttribute" } | ForEach-Object { 
                [PSCustomObject]@{
                    Key = $_.ConstructorArguments[0].Value
                    Value =$_.ConstructorArguments[1].Value
                }
        }
        $assembly.dispose()
    }
    
    end {
        
    }
}