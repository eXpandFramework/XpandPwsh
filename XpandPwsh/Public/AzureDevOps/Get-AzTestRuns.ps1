function Get-AzTestRuns {
    [CmdletBinding()]
    [CmdLetTag(("#Azure","#AzureDevOps"))]
    param (
        [parameter()][switch]$FailedOnly,
        [parameter()][string]$runTitle,
        [parameter()][int[]]$buildIds,
        [parameter(ValueFromPipeline)]
        [ArgumentCompleter( {
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
                (Get-AzDefinition | Where-Object { $_.name -like "$wordToComplete*" }).Name
            })]
        [string[]]$Definition,
        [parameter()][int]$Top,
        [parameter()][int]$Skip,
        [parameter()][datetime]$minLastUpdatedDate=[datetime]::Now.AddDays(-6),
        [parameter()][datetime]$maxLastUpdatedDate=[datetime]::Now,
        [ValidateSet("aborted","completed","inProgress","needsInvestigation","notStarted","unspecified","waiting")]
        [string]$State,
        [parameter()][string]$branchName,
        [parameter()][string]$Project = $env:AzProject,
        [parameter()][string]$Organization = $env:AzOrganization,
        [parameter()][string]$Token = $env:AzureToken
    )
    
    begin {
        if ($buildIds.Count -gt 10){
            throw "buildsIds count should not be more than 10"
        }
        $cred = @{
            Project      = $Project
            Organization = $Organization
            Token        = $Token
        }
    }
    
    process {
        $query = ConvertTo-HttpQueryString @{
            minLastUpdatedDate=$minLastUpdatedDate
            maxLastUpdatedDate=$maxLastUpdatedDate
            '$top' = $top
            '$skip' = $Skip
            runTitle=$runTitle
            buildIds=($buildIds -join ",")
            buildDefIds=(($Definition|Where-Object{$_}|Get-AzDefinition).id -join ",")
            State=$State
            branchName=$branchName
        }
        (Invoke-AzureRestMethod "test/runs$query" @cred)|where-object{
            !$FailedOnly -or ($_.runStatistics|Where-Object{$_.outcome -eq "failed"})
        }
    }
    
    end {
        
    }
}