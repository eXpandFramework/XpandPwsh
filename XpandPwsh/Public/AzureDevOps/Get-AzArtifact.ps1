function Get-AzArtifact {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline,ParameterSetName="definition")]
        [ArgumentCompleter( {
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
                (Get-AzDefinition | Where-Object { $_.name -like "$wordToComplete*" }).Name
            })]
        [string[]]$Definition,
        [parameter(Mandatory,ParameterSetName="BuildId")]
        [int]$BuildId,
        [parameter()]
        [string]$ArtifactName,
        [parameter()]
        [string]$Outpath,
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
        if (!$BuildId){
            $buildId=(Get-AzBuilds -Definition $Definition -Result succeeded -Status completed |Select-Object -First 1).Id
        }
        $endpoint="build/builds/$buildId/artifacts"
        Invoke-AzureRestMethod $endpoint @cred|Where-Object{!$ArtifactName -or $_.name -eq $ArtifactName}|ForEach-Object{
            $_
            if ($Outpath){
                $zip="$Outpath\$ArtifactName.zip"
                Use-Object($c=[System.Net.WebClient]::new()){
                    $c.DownloadFile($_.resource.downloadUrl,$zip)
                }
                Expand-Archive -DestinationPath "$Outpath\$ArtifactName" -Path $zip -Force
                Remove-Item $zip
            }
        }
    }
    end {
        
    }
}