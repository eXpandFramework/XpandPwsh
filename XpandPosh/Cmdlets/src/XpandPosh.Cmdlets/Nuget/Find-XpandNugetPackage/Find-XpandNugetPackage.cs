using System.Linq;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Threading.Tasks;
using XpandPosh.CmdLets;

namespace XpandPosh.Cmdlets.Nuget{
    [Cmdlet(VerbsCommon.Find, "XpandNugetPackage")]
    [CmdletBinding]
    public class FindXpandNugetPackage : NugetCmdlet{

        [Parameter]
        public XpandPackageSource PackageSource{ get; set; } =XpandPackageSource.Nuget;
        
        [Parameter]
        public XpandPackageFilter Filter{ get; set; }

        protected override async Task ProcessRecordAsync(){
            var feed = GetFeed(XpandPackageSource.Xpand);
            var allLabPackages = Providers.ListPackages(feed)
                .Where(FilterMatch);
            if (PackageSource == XpandPackageSource.Xpand){
                await allLabPackages.Distinct().WriteObject(this);
            }
            else{
                feed = GetFeed(XpandPackageSource.Nuget);
                await allLabPackages.SelectMany(id => Providers.ListPackages(feed, id))
                    .Distinct()
                    .WriteObject(this);

            }
        }

        private string GetFeed(XpandPackageSource source){
            return (string) this.Invoke($"Get-packageFeed -{source}").First().BaseObject;
        }

        private bool FilterMatch(string id){
            if (Filter == XpandPackageFilter.Standalone)
                return id.StartsWith("Xpand");
            if (Filter == XpandPackageFilter.Xpand){
                return id.StartsWith("eXpand");
            }

            return id.StartsWith("Xpand") || id.StartsWith("eXpand");
        }
    }

    public enum XpandPackageFilter{
        All,
        Xpand,
        Standalone
    }

    public enum XpandPackageSource{
        Nuget,
        Xpand
    }
}

