using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.GitHub.CheckpointGithubIssue{
    [CmdletBinding(SupportsShouldProcess = true)]
    [Cmdlet(VerbsCommon.New, "GitHubComment", SupportsShouldProcess = true)]
    public class CommentGitHubIssue : GitHubCmdlet{
        [Parameter]
        public int IssueNumber{ get; set; }
        [Parameter(Mandatory = true)]
        public string Comment{ get; set; }
        [Parameter(Mandatory = true)]
        public string Repository{ get; set; }

        protected override Task ProcessRecordAsync(){
            return GitHubClient.Repository.GetForOrg(Organization, Repository)
                .SelectMany(repository => GitHubClient.Issue.Comment.Create(repository.Id, IssueNumber, Comment))
                .WriteObject(this)
                .ToTask();
            return base.ProcessRecordAsync();
        }
    }
}