using System.Linq;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using ImpromptuInterface;
using Octokit;
using XpandPosh.CmdLets;

namespace XpandPosh.Cmdlets.GetGitHubCommitIssue{
    [CmdletBinding]
    [Cmdlet(VerbsCommon.Get, "GitHubCommitIssue")]
    [OutputType(typeof(ICommitIssues))]
    public class GetGitHubCommitIssues : GitHubCmdlet{
        
        [Parameter(Mandatory = true)]
        public string Repository1{ get; set; } 
        [Parameter(Mandatory = true)]
        public string Repository2{ get; set; } 
        [Parameter]
        public string Milestone{ get; set; } 

        protected override Task ProcessRecordAsync(){
            var appClient = NewGitHubClient();
            return appClient.CommitIssues(Organization, Repository1, Repository2,Milestone)
                .Select(_ => _.commitIssues.Select(tuple => (_.repoTuple.repo1,_.repoTuple.repo2,tuple.commit,tuple.issues).ToClass().ActLike<ICommitIssues>()))
                .Catch(this,Repository1)
                .WriteObject(this)
                .ToTask();
        }
        

        
    }
    public interface ICommitIssues{
        Repository Repository1{ get; }
        Repository Repository2{ get; }
        Issue[] Issues{ get; }
        GitHubCommit GitHubCommit{ get; set; }
    }
}