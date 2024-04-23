using System;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using JetBrains.Annotations;
using Octokit;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.GitHub.GetGitHubIssue{
    [CmdletBinding]
    [Cmdlet(VerbsCommon.Get, "GitHubIssue")]
    [CmdLetTag(CmdLetTag.GitHub,CmdLetTag.Reactive,CmdLetTag.RX)][PublicAPI]
    public class GetGitHubIssue : GitHubCmdlet{
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
        [Parameter]
        public string[] Labels{ get; set; }=[];
        [Parameter]
        public string Assignee{ get; set; }
        protected override Task ProcessRecordAsync() 
            => GitHubClient.Repository.GetForOrg(Organization, Repository)
                .SelectMany(repository => {
                    var repositoryIssueRequest = new RepositoryIssueRequest(){
                        Since = Since, Filter = IssueFilter, State = State,Assignee = Assignee
                    };
                    foreach (var label in Labels){
                        repositoryIssueRequest.Labels.Add(label);
                    }
                    return IssueNumber > 0
                        ? GitHubClient.Issue.Get(repository.Id, IssueNumber).ToObservable()
                        : GitHubClient.Issue.GetAllForRepository(repository.Id,
                            repositoryIssueRequest).ToObservable().SelectMany(list => list);
            })
            .WriteObject(this)
            .ToTask();
    }
}