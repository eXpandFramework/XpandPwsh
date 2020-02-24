using System;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using JetBrains.Annotations;
using Octokit;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.GitHub.GetGitHubIssueEvents{
    [CmdletBinding]
    [Cmdlet(VerbsCommon.Get, "GitHubIssueEvents")]
    [PublicAPI]
    public class GetGitHubIssueEvents : GitHubCmdlet{
        [Parameter(Mandatory = true)]
        public string Repository{ get; set; }
        [Parameter(Mandatory = true)]
        public int IssueNumber{ get; set; }
        
        protected override Task ProcessRecordAsync(){
            return GitHubClient.Repository.GetForOrg(Organization, Repository)
                .SelectMany(repository => GitHubClient.Issue.Events.GetAllForIssue(repository.Id, IssueNumber))
                .WriteObject(this)
                .ToTask();
        }
    }
}