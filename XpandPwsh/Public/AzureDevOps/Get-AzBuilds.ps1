function Get-AzBuilds {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
            (Get-AzDefinition |where-object{$_.name -like "$wordToComplete*"}).Name
        })]
        [string[]]$Definition,
        [parameter()][ValidateSet("Canceled","failed","none","partiallySucceeded","succeeded")]
        [string[]]$Result,
        [parameter()][ValidateSet("all","Canceled","completed","inProgress","none","notStarted","postponed")]
        [string[]]$Status,
        [parameter()][ValidateSet( "all", "batchedCI", "buildCompletion", "checkInShelveset", "individualCI", "manual", "pullRequest", "schedule", "triggered", "userCreated", "validateShelveset")]
        [string[]]$Reason,
        [string]$Project=$env:AzProject,
        [string]$Organization=$env:AzOrganization,
        [string]$Token=$env:AzureToken
    )
    
    begin {
        
    }
    
    process {
        $DefinitionIds=(Get-AzDefinition|Where-Object{$_.Name -in $Definition}).id
        (Invoke-AzureRestMethod "build/builds" -Organization $Organization -Project $Project -Token $token)|Where-Object{
            !$Status -or $_.Status -in $Status -and
            !$reason -or $_.reason -in $reason -and
            !$Result -or $_.Result -in $Result -and
            !$DefinitionIds -or $_.Definition.id -in $DefinitionIds
        }
    }
    
    end {
        
    }
}