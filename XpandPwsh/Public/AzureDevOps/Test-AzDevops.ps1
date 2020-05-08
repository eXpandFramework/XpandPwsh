function Test-AzDevops {
    [CmdletBinding()]
    [CmdLetTag((("#Azure","#AzureDevOps")))]
    param (
    )
    
    begin {
        
    }
    
    process {
        $env:Build_DefinitionName
    }
    end {
        
    }
}