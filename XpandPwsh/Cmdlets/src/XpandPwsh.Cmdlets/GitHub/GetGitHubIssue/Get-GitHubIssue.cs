using System;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using Octokit;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.GitHub.GetGitHubIssue{
    [CmdletBinding]
    [Cmdlet(VerbsCommon.Get, "GitHubIssue")]
    public class GetGitHubIssues : GitHubCmdlet{
        [Parameter(Mandatory = true)]
        public string Repository{ get; set; }
        [Parameter]
        public DateTimeOffset? Since{ get; set; }
        [Parameter]
        public IssueFilter IssueFilter{ get; set; }=IssueFilter.All;
        [Parameter]
        public ItemStateFilter State{ get; set; }=ItemStateFilter.Open;
        [Parameter]
        public int IssueNumber{ get; set; }
        protected override Task ProcessRecordAsync(){
            return GitHubClient.Repository.GetForOrg(Organization, Repository)
                .SelectMany(repository => {
                    return IssueNumber > 0
                        ? GitHubClient.Issue.Get(repository.Id, IssueNumber).ToObservable()
                        : GitHubClient.Issue.GetAllForRepository(repository.Id,
                            new RepositoryIssueRequest(){
                                Since = Since, Filter = IssueFilter, State = State
                            }).ToObservable().SelectMany(list => list);
                })
                .WriteObject(this)
                .ToTask();
        }
    }
}