function Get-AzBuilds {
    [CmdletBinding()]
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
        [string[]]$Tag,
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
    }
    
    process {
        $query =ConvertTo-HttpQueryString @{
            top          = $top
            reasonFilter = $Reason
            statusFilter = ($Status-join ",")
            resultFilter = $Result
            tagFilters  = ($Tag -join ",")
            definitions  = (($Definition | Get-AzDefinition).id -join ",")
        }
        (Invoke-AzureRestMethod "build/builds$query" @cred) 
    }
    
    end {
        
    }
}