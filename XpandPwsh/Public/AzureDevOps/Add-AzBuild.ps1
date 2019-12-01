function Add-AzBuild {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [ArgumentCompleter( {
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
                (Get-AzDefinition | Where-Object { $_.name -like "$wordToComplete*" }).Name
            })]
        [string[]]$Definition,
        [switch]$StopOthers,
        [switch]$StopIfRunning,
        [string]$Organization=$env:AzOrganization,
        [string]$Project=$env:AzProject,
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
        $builds=(Get-AzDefinition @cred| Where-Object { $_.name -in $Definition }).id | ForEach-Object {
            $body = @"
            {
                "definition": {
                    "id": $_
                }
            }
"@
            $resp=Invoke-AzureRestMethod "build/builds" -Method Post -Body $body @cred
            Write-Output $resp
        }
        if ($StopOthers -or $StopIfRunning){
            $allBuilds=Get-AzBuilds -Status inProgress, notStarted, postponed @cred
        }
        if ($StopOthers) {
            $allBuilds|Where-Object{$_.id -notin $builds.id} | Remove-AzBuild @cred
        }
        if ($StopIfRunning){
            $allBuilds|Where-Object{$_.id -in $builds.id}|Remove-AzBuild @cred
        }
    }
    end {
        
    }
}