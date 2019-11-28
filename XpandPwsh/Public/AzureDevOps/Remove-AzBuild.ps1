function Remove-AzBuild {
    [CmdletBinding()]
    param (
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [int]$Id,
        [string]$Project=$env:AzProject,
        [string]$Organization=$env:AzOrganization
    )
    
    begin {
        
    }
    
    process {
        Invoke-AzureRestMethod "build/builds/$Id" -Organization $Organization -Project $Project -Method Delete
    }
    
    end {
        
    }
}