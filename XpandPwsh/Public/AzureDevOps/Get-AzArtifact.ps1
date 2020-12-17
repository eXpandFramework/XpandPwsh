function Get-AzArtifact {
    [CmdletBinding()]
    [CmdLetTag(("#Azure","#AzureDevOps"))]
    param (
        [parameter(Mandatory, ValueFromPipeline,ParameterSetName="definition")]
        [ArgumentCompleter( {
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
                (Get-AzDefinition | Where-Object { $_.name -like "$wordToComplete*" }).Name
            })]
        [string[]]$Definition,
        [parameter(Mandatory,ParameterSetName="BuildId",ValueFromPipeline)]
        [int]$BuildId,
        [parameter()]
        [string]$ArtifactName,
        [ValidateScript({Test-path $_ -pathtype Container})]
        [parameter()]
        [System.IO.DirectoryInfo]$Outpath,
        [parameter()][switch]$NoExpandArchive,
        [parameter()][string]$Organization=$env:AzOrganization,
        [parameter()][string]$Project=$env:AzProject,
        [parameter()][string]$Token=$env:AzureToken
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
            if ($Outpath){
                $name=$ArtifactName
                if (!$ArtifactName){
                    $name=$_.name
                }
                $zip="$Outpath\$name.zip"
                Use-Object($c=[System.Net.WebClient]::new()){
                    $c.DownloadFile($_.resource.downloadUrl,$zip)
                }
                if (!$NoExpandArchive){
                    Expand-Archive -DestinationPath "$Outpath\$name" -Path $zip -Force
                    Remove-Item $zip|Out-Null
                    (Get-Item "$Outpath\$name").FullName
                }
                else{
                    Get-Item $zip
                }
                
            }
            else{
                $_
            }
        }|Where-Object{$_}
    }
    end {
        
    }
}