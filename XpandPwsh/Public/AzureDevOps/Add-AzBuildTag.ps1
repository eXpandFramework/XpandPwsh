
function Add-AzBuildTag {
    [CmdletBinding()]
    [CmdLetTag(("#Azure","#AzureDevOps"))]
    param (
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string]$Tag,
        [parameter(ValueFromPipelineByPropertyName)]
        [string]$Id=$env:Build_BuildId,
        [parameter()][string]$Organization = $env:AzOrganization,
        [parameter()][string]$Project = $env:AzProject,
        [parameter()][string]$Token = $env:AzureToken
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