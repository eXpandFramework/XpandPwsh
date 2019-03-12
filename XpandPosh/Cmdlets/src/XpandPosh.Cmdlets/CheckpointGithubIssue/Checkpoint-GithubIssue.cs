using System;
using System.Linq;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading;
using System.Threading.Tasks;
using Octokit;
using SmartFormat;
using XpandPosh.CmdLets;

namespace XpandPosh.Cmdlets.CheckpointGithubIssue{
    [CmdletBinding(SupportsShouldProcess = true)]
    [Cmdlet(VerbsData.Checkpoint, "GitHubIssue",SupportsShouldProcess = true)]
    public class CheckpointGitHubIssue : GitHubCmdlet{
        
        [Parameter(Mandatory = true)]
        public string Repository1{ get; set; } 
        [Parameter(Mandatory = true)]
        public string Repository2{ get; set; } 
        [Parameter(Mandatory = true)]
        public string Message{ get; set; } 
        [Parameter]
        public string Branch{ get; set; } 

        protected override Task ProcessRecordAsync(){
            return LinkCommits()
                .HandleErrors(this,Repository1)
                .WriteObject(this)
                .ToTask();
        }

        private IObservable<PSObject> LinkCommits( ){
            var appClient = NewGitHubClient();
            var synchronizationContext = SynchronizationContext.Current;
            var issueToNotify = appClient
                .LastMileStone(Organization, Repository1)
                .WriteVerboseObject(this,milestone => milestone.Title)
                .SelectMany(milestone => appClient
                    .CommitIssues(Organization, Repository1, Repository2, milestone.Title,Branch)
                    .SelectMany(tuple => {
                        var issues = tuple.commitIssues
                            .SelectMany(_ => _.issues.Select(issue => (_.commit, issue))).ToObservable()
                            .WriteVerboseObject(this,_ => $"Commit ({_.commit.Sha}){_.commit.Commit.Message} links to {_.issue.Number}",synchronizationContext)
                            .SelectMany(_ => appClient.Issue.Comment
                                .GetAllForIssue(tuple.repoTuple.repo1.Id, _.issue.Number)
                                .ToObservable()
                                .ObserveOn(synchronizationContext)
                                .Where(list => {
                                    WriteVerbose($"Searching {list.Count} comments in Issue {_.issue.Number} for {_.commit.Sha}");
                                    var checkpoint = list.Any(comment => comment.Body.Contains(_.commit.Sha));
                                    WriteVerbose($"Checkpoint {(!checkpoint ? " not " : null)}exists");
                                    return !checkpoint;
                                })
                                .Select(list => (repo1: tuple.repoTuple.repo1.Id, repo2: tuple.repoTuple.repo2.Id,_.commit, _.issue)));
                        return issues;
                    }))
                .Replay().RefCount()
                .WriteVerboseObject(this);

            return issueToNotify
                .GroupBy(_ => (_.issue, _.repo1))
                .SelectMany(_ => {
                    return _.TakeUntil(_.LastAsync()).ToArray()
                        .Select(tuples => tuples.Select(valueTuple => valueTuple.commit).ToArray())
                        .Select(hubCommits => (key: _.Key, commits: hubCommits));
                })
                .ObserveOn(synchronizationContext)
                .SelectMany(_ => {
                    var comment = GenerateComment(_);
                    var issue = _.key.issue;
                    var psObject = Observable.Return(new PSObject(new {
                        IssueNumber = issue.Number, Milestone = issue.Milestone?.Title,issue.Title,
                        Commits = string.Join(",", _.commits.Select(commit => commit.Commit.Message)), Comment = comment
                    }));
                    var text = $"Create comment for issue {_.key.issue.Number}";
                    WriteVerbose(text);
                    if (ShouldProcess(text)){
                        return appClient.Issue.Comment.Create(_.key.repo1, _.key.issue.Number, comment)
                            .ToObservable().Select(issueComment => psObject).Concat();
                    }

                    return psObject;
                })
                .DefaultIfEmpty();
        }


        private  string GenerateComment(((Issue issue, long repoId) key, GitHubCommit[] commits) _){
            var objects = new object[] {
                new{
                    Options = this,
                    Commits = string.Join(",",
                        _.commits.Select(commit =>
                            $@"[{commit.Commit.Message}](https://github.com/{Organization}/{Repository2}/commit/{commit.Sha})"))
                }
            };
            var comment = Smart.Format(Message, objects);
            return comment;
        }
    }
}