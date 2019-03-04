using System;
using System.Collections.Generic;
using System.Linq;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using Octokit;

namespace XpandPosh.CmdLets{
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

        public static IObservable<((GitHubCommit commit, Issue[] issues)[] commitIssues, (Repository repo1, Repository repo2) repoTuple)> CommitIssues(
            this GitHubClient appClient, string organization, string repository1,string repository2, string millestone,string branch=null){

            var allRepos = appClient.Repository.GetAllForOrg(organization).ToObservable().Replay().RefCount();
            return allRepos.Select(list => list.First(repository => repository.Name==repository1))
                .Zip(allRepos.Select(list => list.First(repository => repository.Name==repository2)),(repo1, repo2) =>(repo1, repo2) )
                .SelectMany(repoTuple => {
                    return appClient.Issue.LastMilestoneIssues(repoTuple, millestone)
                        .Select(issues => (commitIssues: appClient.Repository.CommitIssues( repoTuple, issues,   millestone,branch),repository: repoTuple));
                });
        }

        public static IObservable<((GitHubCommit, Issue[] issues)[] commitIssues, Repository repository)> CommitIssues(
            this GitHubClient appClient, string organization, string repositoryName, string millestone){
            return appClient.CommitIssues(organization, repositoryName, repositoryName, millestone).Select(tuple => (tuple.commitIssues,tuple.repoTuple.repo1));
        }

        static (GitHubCommit, Issue[] issues)[] CommitIssues(this IRepositoriesClient repositoriesClient,
            (Repository repo1,Repository repo2) repoTuple, Issue[] issues,  string millestone,string branch=null){

            return repositoriesClient.Commits(repoTuple, millestone,branch)
                .SelectMany(commits => commits.Select(commit => (commit,issues: issues.Where(issue => commit.Commit.Message.Contains($"#{issue.Number}")).ToArray())))
                .Where(tuple => tuple.issues.Any())
                .Select(tuple => tuple)
                .ToEnumerable()
                .ToArray();
        }

        static IObservable<IReadOnlyList<GitHubCommit>> Commits(this IRepositoriesClient repositoriesClient,(Repository repo1, Repository repo2) repoTuple,  string millestone,string branch=null){
            return repositoriesClient.LastRelease( repoTuple.repo1,  millestone).SelectMany(_ =>
                    repositoriesClient.Commit.GetAll(repoTuple.repo2.Id, new CommitRequest(){Since = _.PublishedAt,Sha = branch}))
                .Select(list => PopulateCommits(repositoriesClient, repoTuple, list)).Concat();
        }

        private static IObservable<GitHubCommit[]> PopulateCommits(IRepositoriesClient repositoriesClient, (Repository repo1, Repository repo2) repoTuple, IReadOnlyList<GitHubCommit> list){
            return list.ToObservable().Select(commit => repositoriesClient.Commit.Get(repoTuple.repo2.Id,commit.Sha)).Concat().ToArray();
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

        public static IObservable<Issue[]> LastMilestoneIssues(this IIssuesClient issuesClient, (Repository repo1, Repository repo2) repoTuple,string millestone){
            var millestones = issuesClient.Milestone.GetAllForRepository(repoTuple.repo1.Id).ToObservable()
                .Select(list => list.First(milestone => milestone.Title==millestone)).DefaultIfEmpty();
            var lastMilestoneIssues = issuesClient.GetAllForRepository(repoTuple.repo1.Id).ToObservable()
                .CombineLatest(millestones, (issues, milestone) => (issues, milestone))
                .Select(tuple => tuple.issues.Where(issue =>issue.Milestone!=null&& issue.Milestone.Number == tuple.milestone.Number).ToArray())
                .Where(issues => issues.Any())
                .StartWith(new Issue[0][]);
            return lastMilestoneIssues.Replay().RefCount();
        }

        public static GitHubClient CreateClient(string owner,string pass,string githubAApp){
            return new GitHubClient(new ProductHeaderValue(githubAApp)){
                Credentials = new Credentials(owner, pass)
            }; 
        }

        public static IObservable<GitHubCommit> Commits(this GitHubClient appClient, string organization,
            string repository, DateTimeOffset? since=null, string branch = null){
            return appClient.Repository.GetForOrg(organization, repository)
                .SelectMany(_ =>  appClient.Repository.Commit.GetAll(_.Id,new CommitRequest(){Sha = branch,Since = since}).ToObservable().SelectMany(list => list).SelectMany(
                    commit => appClient.Repository.Commit.Get(_.Id, commit.Sha).ToObservable()));
        }

    }
}
