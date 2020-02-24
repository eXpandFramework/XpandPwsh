using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using JetBrains.Annotations;

namespace XpandPwsh.Cmdlets.GitHub.GetGitHubClient{
    [CmdletBinding]
    [Cmdlet(VerbsCommon.Get, "GitHubClient")]
    [PublicAPI]
    public class GetGitHubClient : GitHubCmdlet{
        protected override Task ProcessRecordAsync(){
            return Observable.Return(GitHubClient)
                .WriteObject(this)
                .ToTask();
        }
    }
}