function Get-AzDefinition {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipelineByPropertyName,ValueFromPipeline)]
        [string]$Name,
        [int]$Top,
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
        $query=ConvertTo-HttpQueryString -Variables Name,Top
        $resource="Build/definitions$query"
        Invoke-AzureRestMethod $resource @cred
    }
    
    end {
        
    }
}