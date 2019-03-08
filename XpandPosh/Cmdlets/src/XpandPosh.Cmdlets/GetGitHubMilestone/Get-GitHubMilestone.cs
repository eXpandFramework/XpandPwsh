using System.Linq;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using Octokit;
using XpandPosh.CmdLets;

namespace XpandPosh.Cmdlets.GetGitHubMilestone{
    [CmdletBinding()]
    [Cmdlet(VerbsCommon.Get, "GitHubMilestone")]
    [OutputType(typeof(Issue))]
    public class GetGitHubMilestone : GitHubCmdlet{
        [Parameter(Mandatory = true)]
        public string Repository{ get; set; }
        [Parameter]
        public SwitchParameter Latest{ get; set; }
        protected override async Task ProcessRecordAsync(){
            var appClient = NewGitHubClient();
            var milestones = appClient.Repository.GetAllForOrg(Organization).ToObservable()
                .Select(list => list.First(repository => repository.Name == Repository))
                .SelectMany(repository => appClient.Issue.Milestone.GetAllForRepository(repository.Id))
                .SelectMany(list => list)
                .Catch(this,Repository)
                .Replay().RefCount();
            await milestones;

            if (Latest)
                milestones = Observable.Return(milestones.ToEnumerable().GetMilestone());
            await milestones
                .Catch(this,Repository)
                .WriteObject(this)
                .ToTask();
        }



    }

}