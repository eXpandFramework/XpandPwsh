function GetAzStorageContainer {
    (Get-AzStorageContainer -Context (Get-AzStorageAccount|Where-Object{$_.StorageAccountName -eq $env:AzStorageAccountName}).Context).Name
}

Register-ArgumentCompleter -CommandName Clear-AzStorageBlob -ParameterName Container -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    (Get-AzStorageContainer -Context (Get-AzStorageAccount|Where-Object{$_.StorageAccountName -eq $env:AzStorageAccountName}).Context).Name
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
        if (!$env:AzStorageAccountName){
            throw "env:AzStorageAccountName is null"
        }
    }
    
    process {
        
        Get-AzStorageBlob  -Container $Container -Context (Get-AzStorageAccount|Where-Object{$_.StorageAccountName -eq $env:AzStorageAccountName}).Context | Remove-AzStorageBlob 
    }
    
    end {
        
    }
}
