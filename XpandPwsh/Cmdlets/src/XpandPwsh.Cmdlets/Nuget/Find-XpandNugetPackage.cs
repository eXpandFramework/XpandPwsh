using System;
using System.Linq;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Threading.Tasks;
using JetBrains.Annotations;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.Nuget{
    [Cmdlet(VerbsCommon.Find, "XpandNugetPackage")]
    [CmdletBinding]
    [CmdLetTag(CmdLetTag.Nuget,CmdLetTag.Reactive,CmdLetTag.RX)][PublicAPI]
    public class FindXpandNugetPackage : NugetCmdlet{

        [Parameter(Position = 0)]
        public XpandPackageSource PackageSource{ get; set; } =XpandPackageSource.Nuget;
        
        [Parameter(Position = 1)]
        public XpandPackageFilter Filter{ get; set; }

        protected override async Task ProcessRecordAsync(){
            var packageSource = PackageSource;
            var xpandFeed = GetFeed(XpandPackageSource.Xpand);
            var nugetFeed = GetFeed(XpandPackageSource.Nuget);
            var allLabPackages = GetPackages(packageSource,xpandFeed, nugetFeed, Filter);
            await allLabPackages.WriteObject(this);
        }

        public static IObservable<PSObject> GetPackages(XpandPackageSource packageSource,string xpandFeed,string nugetFeed,XpandPackageFilter filter){
            if (packageSource == XpandPackageSource.Xpand){
                nugetFeed = null;
            }
            else if (packageSource == XpandPackageSource.Nuget){
                xpandFeed = null;
            }
            return Providers.ListXpandPackages(xpandFeed,nugetFeed).ToPackageObject()
                .Where(tuple => FilterMatch(tuple,filter))
                .Select(_ => PSObject.AsPSObject(new{_.Id, _.Version}));
        }

        private string GetFeed(XpandPackageSource source){
            return (string) this.Invoke($"Get-packageFeed -{source}").First().BaseObject;
        }

        private static bool FilterMatch((string Id, Version Version) id,XpandPackageFilter filter){
            if (filter == XpandPackageFilter.Standalone)
                return id.Id.StartsWith("Xpand");
            if (filter == XpandPackageFilter.Xpand){
                return id.Id.StartsWith("eXpand");
            }

            return id.Id.StartsWith("Xpand.") || id.Id.StartsWith("eXpand")||id.Id.EndsWith(".Xpand");
        }
    }

    [PublicAPI]
    public enum XpandPackageFilter{
        All,
        Xpand,
        Standalone,

    }

    public enum XpandPackageSource{
        Nuget,
        Xpand
    }
}

