using System;
using System.Linq;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading;
using System.Threading.Tasks;
using Octokit;
using XpandPosh.CmdLets;

namespace XpandPosh.Cmdlets.CloseGitHubIssue{
    [CmdletBinding(SupportsShouldProcess = true)]
    [Cmdlet(VerbsCommon.Close, "GithubIssue",SupportsShouldProcess = true)]
    [OutputType(typeof(Issue))]
    public class CloseGithubIssue : GithubCmdlet{
        [Parameter(Mandatory = true)]
        public string Repository1{ get; set; } 
        public string Message{ get; set; } ="Closing issue for age. Feel free to reopen it at any time.\r\n\r\n.Thank you for your contribution.";
        public int DaysUntilClose{ get; set; } = 60;

        protected override Task ProcessRecordAsync(){
            var appClient = CreateClient();
            var repository = appClient.Repository.GetAllForOrg(Organization).ToObservable()
                .Select(list => list.First(_ => _.Name == Repository1));
            var filter = new RepositoryIssueRequest{
                SortDirection = SortDirection.Ascending, SortProperty = IssueSort.Updated,
                State = ItemStateFilter.Open
            };

            var context = SynchronizationContext.Current;
            var issuesToClose = repository.SelectMany(_ => appClient.Issue.GetAllForRepository(_.Id, filter))
                .SelectMany(list => list)
                .ObserveOn(context)
                .Where(issue => {
                    var needsClosing = NeedsClosing(issue, DaysUntilClose);
                    WriteVerbose($"Issue {issue.Number} needclose={needsClosing}");
                    return needsClosing;
                })
                .CombineLatest(repository, (issue, repo) => (issue: issue, repo: repo));
            return issuesToClose
                .ObserveOn(context)
                .Do(_ => WriteVerbose($"Closing issue #{_.issue.Number}"))
                .SelectMany(_ => {
                    var issues = CloseIssue(appClient, _).Select(issue => CommentIssue( appClient, _)).Concat();
                    return ShouldProcess("Close Issue") ? issues : Observable.Return(_.issue);
                })
                .DefaultIfEmpty()
                .ObserveOn(context)
                .Do(WriteObject)
                .ToTask();
        }

        private  IObservable<Issue> CommentIssue( GitHubClient appClient, (Issue issue, Repository repo) _){
            return Observable.Defer(() => appClient.Issue.Comment.Create(_.repo.Id, _.issue.Number, Message)
                .ToObservable()).Select(comment => _.issue);
        }

        private static IObservable<Issue> CloseIssue(GitHubClient appClient, (Issue issue, Repository repo) _){
            var issueUpdate = _.issue.ToUpdate();
            issueUpdate.State = ItemState.Closed;
            return appClient.Issue.Update(_.repo.Id, _.issue.Number, issueUpdate).ToObservable().Select(issue => issue);
        }

        private static bool NeedsClosing(Issue issue, int daysUntilClose){
            var totalDays = DateTimeOffset.UtcNow.Subtract(issue.CreatedAt.DateTime).TotalDays;
            if (issue.UpdatedAt.HasValue){
                totalDays = DateTimeOffset.UtcNow.Subtract(issue.UpdatedAt.Value.DateTime).TotalDays;
            }

            return totalDays - daysUntilClose > 0;
        }
    }
}