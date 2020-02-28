using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using JetBrains.Annotations;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.GitHub.PublishGitHubRelease{
    [CmdletBinding]
    [Cmdlet(VerbsCommon.New, "GithubReleaseNotesTemplate")]
    [OutputType(typeof(IReleaseNotesTemplate))]
    [CmdLetTag(CmdLetTag.GitHub,CmdLetTag.Reactive,CmdLetTag.RX)][PublicAPI]
    public class NewGithubReleaseNotesTemplate : XpandCmdlet{
        
        protected override  Task ProcessRecordAsync(){
            return Observable.Return(ReleaseNotesTemplate.Default)
                .HandleErrors(this,"")
                .WriteObject(this)
                .ToTask();
        }
    }
}