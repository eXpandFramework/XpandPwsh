function Get-AzBuildChanges {
    [CmdletBinding()]
    [CmdLetTag(("#Azure", "AzureDevOps"))]
    param (
        [parameter(ValueFromPipeline)]
        [ArgumentCompleter( {
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
                (Get-AzDefinition | Where-Object { $_.name -like "$wordToComplete*" }).Name
            })]
        [parameter()][int]$FromBuildId,
        [parameter()][int]$ToBuildId,
        [parameter()][int]$Top,
        [parameter()][string]$Project = $env:AzProject,
        [parameter()][string]$Organization = $env:AzOrganization,
        [parameter()][string]$Token = $env:AzDevopsToken
    )
    
    begin {
        $cred = @{
            Project      = $Project
            Organization = $Organization
            Token        = $Token
            Version      = "5.1-preview.2"
        }
    }
    
    process {
        $query = ConvertTo-HttpQueryString @{
            '$top'      = $top
            fromBuildId = $FromBuildId
            toBuildId   = $ToBuildId
        }
        $resource = "build/changes$query"
        Invoke-AzureRestMethod $resource @cred
    }
    
    end {
        
    }
}