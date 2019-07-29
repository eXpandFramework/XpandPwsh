using System;
using System.Collections.Generic;
using System.Linq;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Text.RegularExpressions;
using Octokit;

namespace XpandPwsh.CmdLets{
    public static class OctokitExtensions{
        public static IObservable<Milestone> LastMileStone(this GitHubClient gitHubClient,string organization,string repositoryName){
            return gitHubClient.Repository.GetForOrg(organization, repositoryName)
                .SelectMany(repository => gitHubClient.Issue.Milestone.GetAllForRepository(repository.Id).ToObservable()
                    .Select(list => list.Where(milestone => milestone.State.Value == ItemState.Open)
                        .OrderByDescending(milestone => milestone.CreatedAt).First()))
                .FirstAsync();
        }

        public static IObservable<Repository> GetForOrg(this IRepositoriesClient repositoriesClient, string organization,string repositoryName){
            return repositoriesClient.GetAllForOrg(organization).ToObservable()
                .Select(list => list.First(repository => repository.Name == repositoryName));
        }

        public static IObservable<((GitHubCommit commit, Issue[] issues)[] commitIssues, (Repository repo1, Repository repo2) repoTuple)> CommitIssues(this GitHubClient appClient, 
            string organization, string repository1, string repository2,DateTimeOffset? since, string branch = null, ItemStateFilter state = ItemStateFilter.All,DateTimeOffset? until = null){

            var allRepos = appClient.Repository.GetAllForOrg(organization).ToObservable().Replay().RefCount();
            return allRepos.Select(list => list.First(repository => repository.Name==repository1))
                .Zip(allRepos.Select(list => list.First(repository => repository.Name==repository2)),(repo1, repo2) =>(repo1, repo2) )
                .Select(repoTuple => {
                    var allIssues = appClient.Issue
                        .GetAllForRepository(repoTuple.repo1.Id,new RepositoryIssueRequest{ Since = since, State = state}).ToObservable()
                        .SelectMany(list => list).Distinct(issue => issue.Number).ToEnumerable().OrderBy(issue => issue.Number).ToArray();
                    var commits = appClient.Repository.Commit.GetAll(repoTuple.repo2.Id, new CommitRequest{Since = since, Sha = branch, Until = until})
                        .ToObservable().SelectMany(list => list).ToEnumerable().ToArray();
                    var commitIssues = commits.Select(commit => {
                            var issues = allIssues.Where(issue =>  new Regex($@"\#{issue.Number}\b").IsMatch(commit.Commit.Message)).ToArray();
                            return (commit, issues);
                        })
                        .Where(_ => _.issues.Any())
                        .ToArray();
                    return (commitIssues, repoTuple); 
                });
        }

        public static IObservable<Release> LastRelease(this IRepositoriesClient repositoriesClient, Repository repository,  string millestone){
            return repositoriesClient.LastTag(repository, tag => tag.Name!=millestone).Select(tag => tag.Name)
                .SelectMany(tagName => repositoriesClient.Release.GetAll(repository.Id).ToObservable().Select(list => list.First(release => release.TagName==tagName)));
        }

        public static IObservable<RepositoryTag> LastTag(this IRepositoriesClient repositoriesClient, Repository repository,Func<RepositoryTag,bool> gitagFilter=null){
            gitagFilter = gitagFilter ?? (tag => true);
            return repositoriesClient.GetAllTags(repository.Id).ToObservable()
                .Select(tags => tags.Where(gitagFilter ))
                .Select(list => list.First()).FirstAsync();
        }

        public static IObservable<Issue[]> LastMilestoneIssues(this IIssuesClient issuesClient, (Repository repo1, Repository repo2) repoTuple,string millestone=null){
            var millestones = issuesClient.Milestone.GetAllForRepository(repoTuple.repo1.Id).ToObservable()
                .Select(list => list.GetMilestone( millestone)).DefaultIfEmpty();
            var lastMilestoneIssues = issuesClient.GetAllForRepository(repoTuple.repo1.Id).ToObservable()
                .CombineLatest(millestones, (issues, milestone) => (issues, milestone))
                .Select(tuple => tuple.issues.Where(issue =>issue.Milestone!=null&& issue.Milestone.Number == tuple.milestone.Number).ToArray())
                .Where(issues => issues.Any())
                .StartWith(new Issue[0][]);
            return lastMilestoneIssues.Replay().RefCount();
        }

        internal static Milestone GetMilestone(this IEnumerable<Milestone> milestones, string millestone=null){
            var array = milestones.ToArray();
            var version = array.Select(_ => Version.TryParse(_.Title, out var result) ? result : new Version("0.0.0.0")).OrderByDescending(_ => _).First();
            return array.FirstOrDefault(_ => millestone == null ? _.Title == version.ToString() : _.Title == millestone);
        }

        public static GitHubClient CreateClient(string owner,string pass,string githubAApp){
            return new GitHubClient(new ProductHeaderValue(githubAApp)){Credentials = new Credentials(owner, pass)}; 
        }

        public static IObservable<GitHubCommit> Commits(this GitHubClient appClient, string organization,
            string repository, DateTimeOffset? since=null, string branch = null){
            return appClient.Repository.GetForOrg(organization, repository)
                .SelectMany(_ =>  appClient.Repository.Commit.GetAll(_.Id,new CommitRequest(){Sha = branch,Since = since}).ToObservable().SelectMany(list => list).SelectMany(
                    commit => appClient.Repository.Commit.Get(_.Id, commit.Sha).ToObservable()));
        }

    }
}
