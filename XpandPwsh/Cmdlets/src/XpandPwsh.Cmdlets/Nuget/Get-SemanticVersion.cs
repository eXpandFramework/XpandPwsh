using System.Management.Automation;
using System.Threading.Tasks;
using JetBrains.Annotations;
using NuGet.Versioning;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.Nuget {
    [CmdletBinding(SupportsShouldProcess = true)]
    [Cmdlet(VerbsCommon.Get, "SemanticVersion", SupportsShouldProcess = true)]
    [CmdLetTag(CmdLetTag.Nuget, CmdLetTag.Reactive, CmdLetTag.RX)]
    [PublicAPI]
    public class GetSemanticVersion : XpandCmdlet {
        [Parameter(Mandatory = true,Position = 1)] 
        public string Version { get; set; }

        protected override Task ProcessRecordAsync() {
            SemanticVersion.TryParse(Version, out var semanticVersion);
            return Task.FromResult(semanticVersion).WriteObject(this);
        }
    }

}