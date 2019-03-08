using System.Collections.Generic;

namespace XpandPosh.Cmdlets.GetNugetPackageSearchMetadata{
    public class MetadataEqualityComparer : IEqualityComparer<IPackageSourceSearchMetadata>{
        public bool Equals(IPackageSourceSearchMetadata x, IPackageSourceSearchMetadata y){
            return x?.Metadata.Identity.Id == y?.Metadata.Identity.Id &&
                   x.GetNuGetVersion()?.Version == y.GetNuGetVersion()?.Version;
        }

        public int GetHashCode(IPackageSourceSearchMetadata obj){
            return $"{obj.Metadata.Identity.Id}{obj.GetNuGetVersion().Version}".GetHashCode();
        }
    }
}