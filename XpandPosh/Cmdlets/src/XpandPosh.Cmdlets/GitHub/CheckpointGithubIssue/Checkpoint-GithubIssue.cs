using System;
using System.Linq;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading;
using System.Threading.Tasks;
using Octokit;
using SmartFormat;
using XpandPosh.Cmdlets.GitHub.GetGitHubCommitIssue;

namespace XpandPosh.Cmdlets.GitHub.CheckpointGithubIssue{
    [CmdletBinding(SupportsShouldProcess = true)]
    [Cmdlet(VerbsData.Checkpoint, "GitHubIssue",SupportsShouldProcess = true)]
    public class CheckpointGitHubIssue : GitHubCmdlet{
        [Parameter(Mandatory = true)]
        public string Message{ get; set; } 
        [Parameter(Mandatory = true)]
        public ICommitIssues[] CommitIssues{ get; set; }

        protected override Task ProcessRecordAsync(){
            return LinkCommits()
                .HandleErrors(this)
                .WriteObject(this)
                .ToTask();
        }

        private IObservable<PSObject> LinkCommits( ){
            var synchronizationContext = SynchronizationContext.Current;
            var repositories = GitHubClient.Repository.GetAllForOrg(Organization)
                .ToObservable().Replay().AutoConnect()
                .ToEnumerable()
                .SelectMany(list => list)
                .ToArray();
            var issueToNotify = CommitIssues
                    .Select(_ => _.Issues.Select(issue => (_.GitHubCommit, issue)).ToObservable()
                        .WriteVerboseObject(this,__ => $"Commit ({__.GitHubCommit.Sha}){__.GitHubCommit.Commit.Message} links to {__.issue.Number}",synchronizationContext)
                        .SelectMany(tuple => IssueComments(GitHubClient, _, tuple, synchronizationContext)))
                    .Merge();

            return issueToNotify
                .GroupBy(_ => (_.issue, _.repo1,_.repo2))
                .SelectMany(_ => _.TakeUntil(_.LastAsync()).ToArray()
                    .Select(tuples => tuples.Select(valueTuple => valueTuple.GitHubCommit).ToArray())
                    .Select(hubCommits => (key: _.Key, commits: hubCommits)))
                .ObserveOn(synchronizationContext)
                .SelectMany(_ => {
                    var comment = GenerateComment(_,repositories);
                    var issue = _.key.issue;
                    var psObject = Observable.Return(new PSObject(new {
                        IssueNumber = issue.Number, Milestone = issue.Milestone?.Title,issue.Title,
                        Commits = string.Join(",", _.commits.Select(commit => commit.Commit.Message)), Comment = comment
                    }));
                    var text = $"Create comment for issue {_.key.issue.Number}";
                    WriteVerbose(text);
                    if (ShouldProcess(text)){
                        return GitHubClient.Issue.Comment.Create(_.key.repo1, _.key.issue.Number, comment)
                            .ToObservable().Select(issueComment => psObject).Concat();
                    }

                    return psObject;
                })
                .DefaultIfEmpty();
        }

        private IObservable<(long repo1, long repo2, GitHubCommit GitHubCommit, Issue issue)> IssueComments(GitHubClient appClient, ICommitIssues _,
            (GitHubCommit GitHubCommit, Issue issue) tuple, SynchronizationContext synchronizationContext){
            return appClient.Issue.Comment
                .GetAllForIssue(_.Repository1.Id, tuple.issue.Number)
                .ToObservable()
                .ObserveOn(synchronizationContext)
                .Where(list => {
                    WriteVerbose($"Searching {list.Count} comments in Issue {tuple.issue.Number} for {tuple.GitHubCommit.Sha}");
                    var checkpoint = list.Any(comment => comment.Body.Contains(tuple.GitHubCommit.Sha));
                    WriteVerbose($"Checkpoint {(!checkpoint ? " not " : null)}exists");
                    return !checkpoint;
                })
                .Select(list => (repo1: _.Repository1.Id, repo2: _.Repository2.Id, _.GitHubCommit, tuple.issue));
        }

        private string GenerateComment(((Issue issue, long repo1, long repo2) key, GitHubCommit[] commits) _,
            Repository[] repositories){
            var repositoryName = repositories.First(repository => repository.Id==_.key.repo2).Name;
            var objects = new object[] {
                new{
                    Options = this,
                    Commits = string.Join(",",
                        _.commits.Select(commit =>
                            $@"[{commit.Commit.Message}](https://github.com/{Organization}/{repositoryName}/commit/{commit.Sha})"))
                }
            };
            var comment = Smart.Format(Message, objects);
            return comment;
        }
    }
}