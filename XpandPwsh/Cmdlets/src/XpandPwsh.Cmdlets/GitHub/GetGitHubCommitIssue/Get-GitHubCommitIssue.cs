using System;
using System.Linq;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using JetBrains.Annotations;
using Octokit;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.GitHub.GetGitHubCommitIssue{
    [CmdletBinding]
    [Cmdlet(VerbsCommon.Get, "GitHubCommitIssue")]
    [OutputType(typeof(ICommitIssues))]
    [CmdLetTag(CmdLetTag.GitHub,CmdLetTag.Reactive,CmdLetTag.RX)][PublicAPI]
    public class GetGitHubCommitIssues : GitHubCmdlet{
        

        [Parameter(Mandatory = true)]
        public string Repository1{ get; set; } 
        [Parameter(Mandatory = true)]
        public string Repository2{ get; set; } 
        [Parameter]
        public string Branch{ get; set; } 
        [Parameter]
        public DateTimeOffset? Since{ get; set; }
        [Parameter]
        public DateTimeOffset? Until{ get; set; }
        [Parameter]
        public ItemStateFilter ItemStateFilter{ get; set; }=ItemStateFilter.All;
        protected override async Task BeginProcessingAsync(){
            await base.BeginProcessingAsync();
            if (!Since.HasValue){
                var release = await GitHubClient.Repository.GetForOrg(Organization, Repository1)
                    .SelectMany(repository => GitHubClient.Repository.Release.GetAll(repository.Id))
                    .Select(list => list.Where(_ => !_.Draft).Skip(2).First());
                Since = release.PublishedAt;
                WriteVerbose($"Last {Repository1} release {release.Name} was at {release.PublishedAt}");
            }
        }

        protected override Task ProcessRecordAsync(){
            return GitHubClient.CommitIssues(Organization, Repository1, Repository2,Since,Branch,ItemStateFilter,Until)
                .Select(_ => _.commitIssues.Select(tuple => new CommitIssues{Repository1 = _.repoTuple.repo1,Repository2 = _.repoTuple.repo2,GitHubCommit = tuple.commit,Issues = tuple.issues}))
                .HandleErrors(this,Repository1)
                .WriteObject(this)
                .ToTask();
        }
        

        
    }

    public class CommitIssues:ICommitIssues{
        public Repository Repository1{ get; set; }
        public Repository Repository2{ get; set; }
        public Issue[] Issues{ get; set; }
        public GitHubCommit GitHubCommit{ get; set; }
    }
    public interface ICommitIssues{
        Repository Repository1{ get; }
        Repository Repository2{ get; }
        Issue[] Issues{ get; }
        [PublicAPI]
        GitHubCommit GitHubCommit{ get; set; }
    }
}