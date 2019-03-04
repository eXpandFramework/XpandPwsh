using System.Management.Automation;
using Octokit;
using XpandPosh.Cmdlets;

namespace XpandPosh.CmdLets{
    public abstract class GithubCmdlet:XpandCmdlet{
        [Parameter(Mandatory = true)]
        public string GitHubApp{ get; set; } 
        [Parameter(Mandatory = true)]
        public string Owner{ get; set; } 
        [Parameter(Mandatory = true)]
        public string Organization{ get; set; } 
        [Parameter(Mandatory = true)]
        public string Pass{ get; set; }
        protected GitHubClient CreateClient(){
            return OctokitExtensions.CreateClient(Owner, Pass, GitHubApp);
        }

    }
}