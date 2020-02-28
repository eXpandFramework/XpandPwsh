using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using JetBrains.Annotations;
using Octokit;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.GitHub.GetGitHubMilestone{
    [CmdletBinding()]
    [Cmdlet(VerbsCommon.Get, "GitHubMilestone")]
    [OutputType(typeof(Issue))]
    [CmdLetTag(CmdLetTag.GitHub,CmdLetTag.Reactive,CmdLetTag.RX)][PublicAPI]
    public class GetGitHubMilestone : GitHubCmdlet{
        [Parameter(Mandatory = true)]
        public string Repository{ get; set; }
        [Parameter]
        public SwitchParameter Latest{ get; set; }
        protected override async Task ProcessRecordAsync(){
            var milestones = GitHubClient.Repository.GetForOrg(Organization, Repository)
                .SelectMany(repository => GitHubClient.Issue.Milestone.GetAllForRepository(repository.Id))
                .SelectMany(list => list)
                .HandleErrors(this,Repository)
                .Replay().RefCount();
            await milestones;

            if (Latest)
                milestones = Observable.Return(milestones.ToEnumerable().GetMilestone());
            await milestones
                .HandleErrors(this,Repository)
                .WriteObject(this)
                .ToTask();
        }
    }
}