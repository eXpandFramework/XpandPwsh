using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using JetBrains.Annotations;
using Octokit;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.GitHub.GitHubRelease{
    [CmdletBinding()]
    [Cmdlet(VerbsCommon.Get, "GitHubRelease")]
    [OutputType(typeof(Release))]
    [CmdLetTag(CmdLetTag.GitHub,CmdLetTag.Reactive,CmdLetTag.RX)][PublicAPI]
    public class GetGitHubRelease : GitHubCmdlet{
        [Parameter(Mandatory = true)]
        public string Repository{ get; set; }
        [Parameter]
        public SwitchParameter Latest{ get; set; }
        protected override  Task ProcessRecordAsync(){
            return GitHubClient.Repository.GetForOrg(Organization, Repository)
                .SelectMany(repository => Latest ? GitHubClient.Repository.Release.GetLatest(repository.Id).ToObservable()
                        : GitHubClient.Repository.Release.GetAll(repository.Id).ToObservable().SelectMany(list => list))
                .HandleErrors(this,Repository)
                .WriteObject(this)
                .ToTask();            
        }
    }
}