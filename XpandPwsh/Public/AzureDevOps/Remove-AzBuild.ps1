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
                $build = Invoke-AzureRestMethod "build/builds/$Id" @cred
                if ($build.status -in @("inProgress","notStarted","postponed","cancelling")) {
                    Invoke-AzureRestMethod "build/builds/$Id" -Method Patch -Body '{"status":"cancelling"}' @cred
                }
                else{
                    Invoke-AzureRestMethod "build/builds/$Id" -Method Delete @cred
                }
            }
        }
    }
    
    end {
        
    }
}