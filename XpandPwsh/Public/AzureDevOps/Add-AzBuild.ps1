function Add-AzBuild {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [ArgumentCompleter( {
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
                (Get-AzDefinition | Where-Object { $_.name -like "$wordToComplete*" }).Name
            })]
        [string[]]$Definition,
        [string[]]$Tag,
        [hashtable]$Parameters=@{},
        [switch]$KeepForEver,
        [switch]$StopOthers,
        [switch]$StopIfRunning,
        [string]$Organization = $env:AzOrganization,
        [string]$Project = $env:AzProject,
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
        if ($StopIfRunning) {
            Get-AzBuilds -Status inProgress, notStarted, postponed @cred | Where-Object { $_.definition.name -eq $Definition } | Remove-AzBuild @cred
        }
        $builds = (Get-AzDefinition @cred | Where-Object { $_.name -in $Definition }).id | ForEach-Object {
            $body = @{
                definition  = @{id = $_ }
                parameters  = $Parameters | ConvertTo-Json
                keepForEver = $KeepForEver.IsPresent
            }
            Invoke-AzureRestMethod "build/builds" -Method Post -Body ($body | ConvertTo-Json) @cred
        }
        
        if ($StopOthers) {
            Get-AzBuilds -Status inProgress, notStarted, postponed @cred | Where-Object { $_.id -notin $builds.id } | Remove-AzBuild @cred
        }
        
    }
    end {
        
    }
}