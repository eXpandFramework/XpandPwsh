function Get-NugetPackageMetadataVersion {
    [CmdletBinding()]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [NuGet.Protocol.Core.Types.IPackageSearchMetadata]$metadata
    )
    
    begin {
    }
    
    process {
        $typeName=$metadata.GetType().Name
        $version=$metadata.Version
        if ($typeName -eq "LocalPackageSearchMetadata"){
            $version=$metadata.Identity.Version
        }
        [PSCustomObject]@{
            Name = $metadata.Identity.Id
            Version = $version.ToString()
        }
    }
    
    end {
    }
}