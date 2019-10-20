function Get-AssemblyMetadata{
    [CmdletBinding()]
    param (
        [System.Reflection.Assembly]$Assembly
    )
    
    begin {
        
    }
    
    process {
        [reflection.customattributedata]::GetCustomAttributes($assembly) | 
            Where-Object { $_.AttributeType -like "System.Reflection.AssemblyMetadataAttribute" } | ForEach-Object { 
                [PSCustomObject]@{
                    Key = $_.ConstructorArguments[0].Value
                    Value =$_.ConstructorArguments[1].Value
                }
        }
    }
    
    end {
        
    }
}