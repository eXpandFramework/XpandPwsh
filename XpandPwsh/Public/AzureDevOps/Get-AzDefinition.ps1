function Get-AzDefinition {
    [CmdletBinding()]
    param (
        $FilterName="*",
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
        Invoke-AzureRestMethod "Build/definitions" @cred
    }
    
    end {
        
    }
}