using namespace System.Management.Automation
class AzBlobContainerNamesGenerator : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        return (Get-AzStorageContainer -Context (Get-AzStorageAccount).Context).Name
    }
}
function Clear-AzStorageBlob {
    [CmdletBinding()]
    param (
        # The Container Name
        [Parameter(Mandatory)]
        [string][ValidateSet([AzBlobContainerNamesGenerator])]
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