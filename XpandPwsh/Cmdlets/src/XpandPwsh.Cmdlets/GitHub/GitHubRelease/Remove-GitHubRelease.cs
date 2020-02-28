using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using JetBrains.Annotations;
using Octokit;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.GitHub.GitHubRelease{
    [CmdletBinding()]
    [Cmdlet(VerbsCommon.Remove, "GitHubRelease")]
    [OutputType(typeof(Release))]
    [CmdLetTag(CmdLetTag.GitHub,CmdLetTag.Reactive,CmdLetTag.RX)][PublicAPI]
    public class RemoveGitHubRelease : GitHubCmdlet{
        [Parameter(Mandatory = true)]
        public string Repository{ get; set; }
        [Parameter]
        public int ReleaseId{ get; set; }
        protected override  Task ProcessRecordAsync(){
            return GitHubClient.Repository.GetForOrg(Organization, Repository)
                .SelectMany(repository => GitHubClient.Repository.Release.Delete(repository.Id,ReleaseId).ToObservable())
                .HandleErrors(this,Repository)
                .WriteObject(this)
                .ToTask();            
        }
    }
}