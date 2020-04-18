function Get-AzProjects {
    [CmdletBinding()]
    [CmdLetTag(("#Azure","AzureDevOps"))]
    param (
        [parameter()]
        [ValidateSet("all","createPending","deleted","deleting","new","unchanged","wellformed")]
        [string]$StateFilter,
        [parameter()][string]$Project=$env:AzProject,
        [parameter()][string]$Organization=$env:AzOrganization,
        [parameter()][string]$Token=$env:AzDevopsToken
    )
    
    begin {
        $cred=@{
            Project="AzDevOpsProjectRestApi"
            Organization=$Organization
            Token=$Token
        }   
    }
    
    process {
        $query=ConvertTo-HttpQueryString -Variables StateFilter
        $resource="projects/$query"
        Invoke-AzureRestMethod $resource @cred
    }
    
    end {
        
    }
}