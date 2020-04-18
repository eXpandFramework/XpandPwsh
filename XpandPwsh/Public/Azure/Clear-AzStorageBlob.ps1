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
        if (!(Get-Module Az -ListAvailable -ErrorAction SilentlyContinue)){
            Install-Module -Name Az -AllowClobber -Scope CurrentUser    
        }
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
