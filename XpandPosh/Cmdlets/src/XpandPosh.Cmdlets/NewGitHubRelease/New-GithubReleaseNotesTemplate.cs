using System.Linq;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using XpandPosh.CmdLets;

namespace XpandPosh.Cmdlets.NewGitHubRelease{
    [CmdletBinding]
    [Cmdlet(VerbsCommon.New, "GithubReleaseNotesTemplate")]
    [OutputType(typeof(IReleaseNotesTemplate))]
    public class NewGithubReleaseNotesTemplate : XpandCmdlet{
        
        protected override  Task ProcessRecordAsync(){
            return Observable.Return(ReleaseNotesTemplate.Default)
                .Catch(this,"")
                .WriteObject(this)
                .ToTask();
        }
    }
}