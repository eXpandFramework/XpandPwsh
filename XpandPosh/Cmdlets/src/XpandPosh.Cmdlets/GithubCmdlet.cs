using System.Management.Automation;
using Octokit;

namespace XpandPosh.CmdLets{
    public abstract class GitHubCmdlet:XpandCmdlet{
        [Parameter()]
        public string GitHubApp{ get; set; } 
        [Parameter(Mandatory = true)]
        public string Owner{ get; set; } 
        [Parameter(Mandatory = true)]
        public string Organization{ get; set; } 
        [Parameter(Mandatory = true)]
        public string Pass{ get; set; }

        protected GitHubClient NewGitHubClient() => OctokitExtensions.CreateClient(Owner, Pass, ActivityName);
    }
}