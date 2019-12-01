
function Add-AzBuildTag {
    [CmdletBinding()]
    param (
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [int]$Id,
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string]$Tag,
        [string]$Organization = $env:AzOrganization,
        [string]$Project = $env:AzProject,
        [string]$Token = $env:AzDevopsToken
    )
    
    begin {
        $cred = @{
            Project      = $Project
            Organization = $Organization
            Token        = $Token
        }   
    }
    
    process {
         Invoke-AzureRestMethod "build/builds/$id/tags/$tag" -Method Put  @cred
        
    }
    end {
        
    }
}