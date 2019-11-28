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
        [string]$Organization=$env:AzOrganization,
        [string]$Project=$env:AzProject
    )
    
    begin {
        
    }
    
    process {
        $builds=(Get-AzDefinition | Where-Object { $_.name -in $Definition }).id | ForEach-Object {
            $body = @"
            {
                "definition": {
                    "id": $_
                }
            }
"@
            $resp=Invoke-AzureRestMethod "build/builds" -Organization $Organization -Project $Project -Method Post -Body $body    
            Write-Output $resp
        }
        if ($StopOthers) {
            Get-AzBuilds -Status inProgress, notStarted, postponed|Where-Object{$_.id -notin $builds.id} | Remove-AzBuild
        }
    }
    end {
        
    }
}