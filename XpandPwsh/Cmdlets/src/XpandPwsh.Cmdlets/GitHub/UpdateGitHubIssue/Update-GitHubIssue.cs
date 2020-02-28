using System.Linq;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using JetBrains.Annotations;
using Octokit;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.GitHub.UpdateGitHubIssue{
    [CmdletBinding(SupportsShouldProcess = true)]
    [Cmdlet(VerbsData.Update, "GitHubIssue",SupportsShouldProcess = true)]
    [OutputType(typeof(Issue))]
    [CmdLetTag(CmdLetTag.GitHub,CmdLetTag.Reactive,CmdLetTag.RX)][PublicAPI]
    public class UpdateGitHubIssue : GitHubCmdlet{
        [Parameter(Mandatory = true,ValueFromPipeline = true)]
        public int IssueNumber{ get; set; }
        [Parameter(Mandatory = true)]
        public string Repository{ get; set; }

        [Parameter]
        public string MileStoneTitle{ get; set; }

        [Parameter]
        public ItemState? State{ get; set; }
        [Parameter]
        public string[] Labels{ get; set; } = new string[0];
        [Parameter]
        public string[] RemoveLabels{ get; set; } = new string[0];

        protected override async Task ProcessRecordAsync(){
            
            var repository = await GitHubClient.Repository.GetForOrg(Organization, Repository);
            var issue = await GitHubClient.Issue.Get(repository.Id, IssueNumber);
            var issueUpdate = new IssueUpdate(){Milestone = issue.Milestone?.Number};
            if (MileStoneTitle!=null){
                var milestone = await GitHubClient.Issue.Milestone.GetAllForRepository(repository.Id).ToObservable().SelectMany(list => list).FirstAsync(_ => _.Title==MileStoneTitle);
                issueUpdate.Milestone = milestone.Number;
            }

            if (State.HasValue){
                issueUpdate.State=State;
            }

            if (Labels != null||RemoveLabels!=null){
                foreach (var label in issue.Labels.Select(label => label.Name.ToLower()).Except(RemoveLabels.Select(s => s.ToLower()))){
                    issueUpdate.AddLabel(label);
                }
                if (Labels!=null){
                    foreach (var label in Labels){
                        issueUpdate.AddLabel(label);
                    }
                }

                if (RemoveLabels != null){
                    foreach (var label in RemoveLabels){
                        issueUpdate.RemoveLabel(label);
                    }
                }
            }
            
            await GitHubClient.Issue.Update(repository.Id, IssueNumber, issueUpdate)
                .ToObservable()
                .WriteObject(this)
                .HandleErrors(this);
        }



    }

}