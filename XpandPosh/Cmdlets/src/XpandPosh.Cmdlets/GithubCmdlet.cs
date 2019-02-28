using System.Management.Automation;
using Octokit;

namespace XpandPosh.CmdLets{
    public abstract class GithubCmdlet:AsyncCmdlet{
        [Parameter(Mandatory = true)]
        public string GitHubApp{ get; set; } 
        [Parameter(Mandatory = true)]
        public string Owner{ get; set; } 
        [Parameter(Mandatory = true)]
        public string Organization{ get; set; } 
        [Parameter(Mandatory = true)]
        public string Pass{ get; set; }
        protected GitHubClient CreateClient(){
            return OctokitEx.CreateClient(Owner, Pass, GitHubApp);
        }

    }
}