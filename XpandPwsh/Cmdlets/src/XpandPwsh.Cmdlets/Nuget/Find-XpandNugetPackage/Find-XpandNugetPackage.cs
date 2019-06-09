using System;
using System.Linq;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Threading.Tasks;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.Nuget{
    [Cmdlet(VerbsCommon.Find, "XpandNugetPackage")]
    [CmdletBinding]
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

        public static IObservable<string> GetPackages(XpandPackageSource packageSource,string xpandFeed,string nugetFeed,XpandPackageFilter filter){
            var allLabPackages = Providers.ListPackages(xpandFeed)
                .Where(s => FilterMatch(s,filter));
            if (packageSource == XpandPackageSource.Nuget){
                allLabPackages = allLabPackages.SelectMany(id => Providers.ListPackages(nugetFeed, id));
            }
            return allLabPackages.Distinct();
        }

        private string GetFeed(XpandPackageSource source){
            return (string) this.Invoke($"Get-packageFeed -{source}").First().BaseObject;
        }

        private static bool FilterMatch(string id,XpandPackageFilter filter){
            if (filter == XpandPackageFilter.Standalone)
                return id.StartsWith("Xpand");
            if (filter == XpandPackageFilter.Xpand){
                return id.StartsWith("eXpand");
            }

            return id.StartsWith("Xpand") || id.StartsWith("eXpand");
        }
    }

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

