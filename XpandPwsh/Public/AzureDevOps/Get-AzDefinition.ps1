function Get-AzDefinition {
    [CmdletBinding()]
    [CmdLetTag(("#Azure","#AzureDevOps"))]
    param (
        [parameter(ValueFromPipelineByPropertyName,ValueFromPipeline)]
        [string]$Name,
        [parameter()][int]$Top,
        [parameter()][string]$Project=$env:AzProject,
        [parameter()][string]$Organization=$env:AzOrganization,
        [parameter()][string]$Token=$env:AzDevopsToken
    )
    
    begin {
        $cred=@{
            Project=$Project
            Organization=$Organization
            Token=$Token
        }   
    }
    
    process {
        $query=ConvertTo-HttpQueryString -Variables Name,Top
        $resource="Build/definitions$query"
        Invoke-AzureRestMethod $resource @cred
    }
    
    end {
        
    }
}