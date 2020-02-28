function Get-Assembly {
    [CmdletBinding()]
    [CmdLetTag("#dotnet")]
    param (
        [parameter(ValueFromPipeline)]
        [string]$name="*"
    )
    
    begin {
        
    }
    
    process {
        [System.AppDomain]::CurrentDomain.GetAssemblies()|Where-Object{
            $_.GetName().Name -like $name
        }
    }
    
    end {
        
    }
}