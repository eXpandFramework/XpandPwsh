function Remove-AzBuildInProgress {
    [CmdletBinding()]
    [CmdLetTag(("#Azure","#AzureDevOps"))]
    param (
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [int]$Id,
        [parameter()][string]$Project=$env:AzProject,
        [parameter()][string]$Organization=$env:AzOrganization,
        [parameter()][string]$Token=$env:AzureToken
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