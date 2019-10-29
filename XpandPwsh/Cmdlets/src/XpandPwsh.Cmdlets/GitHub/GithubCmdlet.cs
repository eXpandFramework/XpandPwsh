using System.Management.Automation;
using System.Threading.Tasks;
using Octokit;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.GitHub{
    public abstract class GitHubCmdlet:XpandCmdlet{
        
        [Parameter(Mandatory = true,ParameterSetName = nameof(Owner))]
        public string Owner{ get; set; } 
        [Parameter(Mandatory = true)]
        public string Organization{ get; set; } 
        [Parameter(Mandatory = true,ParameterSetName = nameof(Token))]
        public string Token{ get; set; } 
        [Parameter(Mandatory = true,ParameterSetName = nameof(Owner))]
        public string Pass{ get; set; }

        protected override Task BeginProcessingAsync(){
            var task = base.BeginProcessingAsync();
            GitHubClient = OctokitExtensions.CreateClient(Owner, Pass, ActivityName,Token);
            return task;
        }

        public GitHubClient GitHubClient{ get; private set; }
    }
}