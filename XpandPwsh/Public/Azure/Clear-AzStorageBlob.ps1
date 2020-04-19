function GetAzStorageContainer {
    (Get-AzStorageContainer -Context (Get-AzStorageAccount|Where-Object{$_.StorageAccountName -eq $env:AzStorageAccountName}).Context).Name
}

function Clear-AzStorageBlob {
    [CmdLetTag("#Azure")]
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
        . $XpandPwshPath\Private\InstallAz.ps1
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
