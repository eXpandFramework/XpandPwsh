function Get-NugetPackageMetadataVersion {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [NuGet.Protocol.Core.Types.IPackageSearchMetadata]$metadata
    )
    
    begin {
    }
    
    process {
        $version = $metadata.Version
        if (!$version) {
            $version = $metadata.Identity.Version
        }
        [PSCustomObject]@{
            Name    = $metadata.Identity.Id
            Version = $version.ToString()
        }
    }
    
    end {
    }
}