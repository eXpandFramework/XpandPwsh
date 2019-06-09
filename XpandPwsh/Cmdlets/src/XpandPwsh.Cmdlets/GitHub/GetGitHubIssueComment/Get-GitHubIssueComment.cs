using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using Octokit;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.GitHub.GetGitHubIssueComment{
    [CmdletBinding]
    [Cmdlet(VerbsCommon.Get, "GitHubIssueComment")]
    public class GetGitHubIssueComment : GitHubCmdlet{
        [Parameter(Mandatory = true)]
        public string Repository{ get; set; }
        [Parameter(Mandatory = true,ValueFromPipeline = true)]
        public Issue Issue{ get; set; }

        protected override Task ProcessRecordAsync(){
            return GitHubClient.Repository.GetForOrg(Organization, Repository)
                .SelectMany(_ => GitHubClient.Issue.Comment.GetAllForIssue(_.Id, Issue.Number))
                .WriteObject(this)
                .ToTask();
            
        }
    }
}