function Get-AzBuilds {
    [CmdletBinding()]
    [CmdLetTag(("#Azure", "AzureDevOps"))]
    param (
        [parameter(ValueFromPipeline)]
        [ArgumentCompleter( {
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
                (Get-AzDefinition | Where-Object { $_.name -like "$wordToComplete*" }).Name
            })]
        [string[]]$Definition,
        [parameter()][ValidateSet("Canceled", "failed", "none", "partiallySucceeded", "succeeded")]
        [string[]]$Result,
        [parameter()][ValidateSet("all", "Canceled", "completed", "inProgress", "none", "notStarted", "postponed")]
        [string[]]$Status,
        [parameter()][ValidateSet( "all", "batchedCI", "buildCompletion", "checkInShelveset", "individualCI", "manual", "pullRequest", "schedule", "triggered", "userCreated", "validateShelveset")]
        [string[]]$Reason,
        [int]$Top,
        [int]$Skip,
        [string[]]$Tag,
        [parameter(ParameterSetName = "Id")]
        [int]$Id,
        [string]$BranchName,
        [string]$Project = $env:AzProject,
        [string]$Organization = $env:AzOrganization,
        [string]$Token = $env:AzDevopsToken
    )
    
    begin {
        $cred = @{
            Project      = $Project
            Organization = $Organization
            Token        = $Token
        }
        if ($BranchName -and $BranchName -notlike "refs/heads/"){
            $BranchName="refs/heads/$BranchName"
        }
    }
    
    process {
        $resource = "build/builds/$id"
        if (!$Id) {
            $query = ConvertTo-HttpQueryString @{
                '$top'       = $top
                '$skip'      = $Skip
                reasonFilter = $Reason
                branchName   = $BranchName
                statusFilter = ($Status -join ",")
                resultFilter = $Result
                tagFilters   = ($Tag -join ",")
                definitions  = (($Definition | Where-Object { $_ } | Get-AzDefinition @cred).id -join ",")
            }
            $resource = "build/builds$query"
        }
        Invoke-AzureRestMethod $resource @cred
    }
    
    end {
        
    }
}