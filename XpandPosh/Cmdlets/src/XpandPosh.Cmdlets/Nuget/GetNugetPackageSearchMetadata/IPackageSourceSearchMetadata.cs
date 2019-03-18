using NuGet.Protocol.Core.Types;

namespace XpandPosh.Cmdlets.Nuget.GetNugetPackageSearchMetadata{
    public class PackageSourceSearchMetadata:IPackageSourceSearchMetadata{
        public string Source{ get; set; }
        public IPackageSearchMetadata Metadata{ get; set; }
    }
    public interface IPackageSourceSearchMetadata{
        string Source{ get; }
        IPackageSearchMetadata Metadata{ get; }
    }
}