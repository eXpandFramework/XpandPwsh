using NuGet.Protocol;
using NuGet.Versioning;
using XpandPosh.Cmdlets.GetNugetPackageSearchMetadata;

namespace XpandPosh.Cmdlets{
    internal static class PackageSearchMetatadataExtensions{
        public static NuGetVersion GetNuGetVersion(this IPackageSourceSearchMetadata metadata){
            if (metadata.Metadata is PackageSearchMetadata searchMetadata)
                return searchMetadata.Version;
            if (metadata.Metadata is LocalPackageSearchMetadata localPackageSearchMetadata)
                return localPackageSearchMetadata.Identity.Version;
            return ((PackageSearchMetadataV2Feed) metadata.Metadata).Version;
        }
    }
}