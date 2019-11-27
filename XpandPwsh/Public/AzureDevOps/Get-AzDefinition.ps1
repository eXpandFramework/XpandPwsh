function Get-AzDefinition {
    [CmdletBinding()]
    param (
        $FilterName="*"
    )
    
    begin {
        
    }
    
    process {
        $o=az pipelines build definition list|ConvertFrom-Json
        $o|Where-Object{$_.name -like "$FilterName"}
    }
    
    end {
        
    }
}