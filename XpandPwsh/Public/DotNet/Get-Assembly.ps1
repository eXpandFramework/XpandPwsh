function Get-Assembly {
    [CmdletBinding()]
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