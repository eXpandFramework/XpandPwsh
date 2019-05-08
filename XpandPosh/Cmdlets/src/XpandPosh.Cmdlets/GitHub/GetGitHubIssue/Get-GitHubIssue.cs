using System;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using Octokit;
using XpandPosh.CmdLets;

namespace XpandPosh.Cmdlets.GitHub.GetGitHubIssue{
    [CmdletBinding]
    [Cmdlet(VerbsCommon.Get, "GitHubIssue")]
    public class GetGitHubIssues : GitHubCmdlet{
        [Parameter(Mandatory = true)]
        public string Repository{ get; set; }
        [Parameter]
        public DateTimeOffset? Since{ get; set; }
        [Parameter]
        public IssueFilter IssueFilter{ get; set; }=IssueFilter.All;
        public ItemStateFilter State{ get; set; }=ItemStateFilter.Open;

        protected override Task ProcessRecordAsync(){
            return GitHubClient.Repository.GetForOrg(Organization, Repository)
                .SelectMany(repository => GitHubClient.Issue.GetAllForRepository(repository.Id,
                    new RepositoryIssueRequest(){
                        Since = Since, Filter = IssueFilter,State = State
                    }))
                .WriteObject(this)
                .ToTask();
        }
    }
}