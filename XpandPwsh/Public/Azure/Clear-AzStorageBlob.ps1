function GetAzStorageContainer {
    (Get-AzStorageContainer -Context (Get-AzStorageAccount).Context).Name
}

Register-ArgumentCompleter -CommandName Clear-AzStorageBlob -ParameterName Container -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    (Get-AzStorageContainer -Context (Get-AzStorageAccount).Context).Name
}
function Clear-AzStorageBlob {
    [CmdletBinding()]
    param (
        # The Container Name
        [Parameter(Mandatory)]
        [string][ArgumentCompleter( {
                GetAzStorageContainer
            })]
        $Container
    )
    
    begin {
        
    }
    
    process {
        Get-AzStorageBlob  -Container $Container -Context (Get-AzStorageAccount).Context | Remove-AzStorageBlob 
    }
    
    end {
        
    }
}
