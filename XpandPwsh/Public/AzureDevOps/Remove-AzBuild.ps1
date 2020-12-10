function Remove-AzBuild {
    [CmdletBinding()]
    [CmdLetTag(("#Azure","#AzureDevOps"))]
    param (
        [parameter(ValueFromPipelineByPropertyName,ParameterSetName="id")]
        [string]$Id,
        [parameter(ParameterSetName="switch")]
        [switch]$InProgress,
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
        if($InProgress){
            Get-AzBuilds -Status inProgress,notStarted|Remove-AzBuild
        }
        else{
            if ($Id){
                Invoke-AzureRestMethod "build/builds/$Id" @cred -Method Delete
            }
        }
    }
    
    end {
        
    }
}