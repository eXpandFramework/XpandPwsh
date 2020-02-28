
function Add-AzBuildTag {
    [CmdletBinding()]
    [CmdLetTag(("#Azure","AzureDevOps"))]
    param (
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string]$Tag,
        [parameter(ValueFromPipelineByPropertyName)]
        [string]$Id=$env:Build_BuildId,
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