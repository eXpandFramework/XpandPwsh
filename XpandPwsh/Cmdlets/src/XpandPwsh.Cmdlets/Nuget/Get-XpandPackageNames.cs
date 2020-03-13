using System.Linq;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Threading.Tasks;
using JetBrains.Annotations;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.Nuget{
    [Cmdlet(VerbsCommon.Get, "XpandPackageNames")]
    [CmdletBinding]
    [CmdLetTag(CmdLetTag.Nuget,CmdLetTag.Reactive,CmdLetTag.RX)][PublicAPI]
    public class GetXpandPackageNames : NugetCmdlet{
        
        protected override async Task ProcessRecordAsync(){
            var xpandFeed = (string) this.Invoke("Get-packageFeed -Xpand").First().BaseObject;
            var nugetFeed = (string) this.Invoke("Get-packageFeed -Nuget").First().BaseObject;
            var packageNames = Providers.ListXpandPackages(xpandFeed, nugetFeed)
                .Select(metadata => metadata.Identity.Id)
                .WriteObject(this)
                .HandleErrors(this)
                .Replay().RefCount();

            await packageNames;

            WriteObject(packageNames.ToEnumerable().OrderBy(s => s),true);
        }

    }
}

