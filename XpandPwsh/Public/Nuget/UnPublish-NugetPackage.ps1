function UnPublish-NugetPackage {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [string]$Name,
        [parameter(Mandatory)]
        [string]$NugetApiKey,
        [parameter(Mandatory)]
        [string]$Source,
        [parameter(Mandatory)]
        [string]$Version
    )
    
    begin {
        $nuget=Get-NugetPath
    }
    
    process {
        & $nuget Delete $name $version -Source $source -ApiKey $NugetApiKey -NonInteractive
    }
    
    end {
    }
}