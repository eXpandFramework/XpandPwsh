using System.Management.Automation;
using System.Threading.Tasks;
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

        protected override Task BeginProcessingAsync(){
            GitHubClient = OctokitExtensions.CreateClient(Owner, Pass, ActivityName);
            return base.BeginProcessingAsync();
        }

        public GitHubClient GitHubClient{ get; private set; }
    }
}