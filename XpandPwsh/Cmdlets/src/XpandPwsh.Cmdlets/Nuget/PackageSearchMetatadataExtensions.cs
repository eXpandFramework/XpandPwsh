using NuGet.Protocol;
using NuGet.Protocol.Core.Types;
using NuGet.Versioning;

namespace XpandPwsh.Cmdlets.Nuget{
    internal static class PackageSearchMetatadataExtensions{
        public static NuGetVersion GetNuGetVersion(this IPackageSearchMetadata metadata){
            if (metadata is PackageSearchMetadata searchMetadata)
                return searchMetadata.Version;
            if (metadata is LocalPackageSearchMetadata localPackageSearchMetadata)
                return localPackageSearchMetadata.Identity.Version;
            return ((PackageSearchMetadataV2Feed) metadata).Version;
        }
    }
}