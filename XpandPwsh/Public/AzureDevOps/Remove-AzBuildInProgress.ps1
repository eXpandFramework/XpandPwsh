function Remove-AzBuildInProgress {
    [CmdletBinding()]
    param (
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [int]$Id,
        [string]$Project=$env:AzProject,
        [string]$Organization=$env:AzOrganization,
        [string]$Token=$env:AzDevopsToken
    )
    
    begin {
        $cred=@{
            Project=$Project
            Organization=$Organization
            Token=$Token
        }        
    }
    
    process {
        Invoke-AzureRestMethod "build/builds/$Id" @cred -Method Delete
    }
    
    end {
        
    }
}