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
        $DefinitionIds=(Get-AzDefinition @cred|Where-Object{$_.Name -in $Definition}).id
        (Invoke-AzureRestMethod "build/builds" @cred)|Where-Object{
            $statusCheck=!$Status -or ( $_.Status -and $_.Status -in $Status)
            $reasonChck=!$reason -or ($_.reason -and $_.reason -in $reason)
            $resultCheck=!$Result -or ($_.Result  -and $_.Result -in $Result)
            $definitionCheck=!$DefinitionIds -or $_.Definition.id -in $DefinitionIds
            $statusCheck -and $reasonChck -and $resultCheck -and $definitionCheck
        }
    }
    
    end {
        
    }
}