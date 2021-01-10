function Get-AzBuilds {
    [CmdletBinding()]
    [CmdLetTag(("#Azure", "#AzureDevOps"))]
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
        [parameter()][int]$Top,
        [parameter()][int]$Skip,
        [parameter()][string[]]$Tag,
        [parameter(ParameterSetName = "Id")]
        [int]$Id,
        [parameter()][string]$BranchName=$env:Build_SourceBranchName,
        [parameter()][string]$Project = $env:AzProject,
        [parameter()][string]$Organization = $env:AzOrganization,
        [parameter()][string]$Token = $env:AzureToken
    )
    
    begin {
        $cred = @{
            Project      = $Project
            Organization = $Organization
            Token        = $Token
        }
        if ($BranchName -and $BranchName -notlike "refs/heads/*"){
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