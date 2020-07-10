function UnPublish-NugetPackage {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [parameter(Mandatory,ValueFromPipeline,ParameterSetName="One")]
        [parameter(Mandatory,ValueFromPipeline,ParameterSetName="All")]
        [string]$Name,
        [parameter(Mandatory,ParameterSetName="One")]
        [parameter(Mandatory,ParameterSetName="All")]
        [string]$NugetApiKey,
        [parameter(Mandatory,ParameterSetName="One")]
        [parameter(Mandatory,ParameterSetName="All")]
        [string]$Source,
        [parameter(Mandatory,ParameterSetName="One")]
        [string]$Version,
        [parameter(ParameterSetName="All")]
        [switch]$AllVersions
    )
    
    begin {
        $nuget=Get-NugetPath
    }
    
    process {
        if ($AllVersions){
            (Get-NugetPackageSearchMetadata $Name -AllVersions -Source $Source).Identity.Version.Version|ForEach-Object{
                & $nuget Delete $name $_ -Source $source -ApiKey $NugetApiKey -NonInteractive
            }
        }
        else{
            & $nuget Delete $name $version -Source $source -ApiKey $NugetApiKey -NonInteractive
        }
        
    }
    
    end {
    }
}