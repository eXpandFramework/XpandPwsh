using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using JetBrains.Annotations;
using Octokit;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.GitHub.GetGitHubRelease{
    [CmdletBinding()]
    [Cmdlet(VerbsCommon.Get, "GitHubRelease")]
    [OutputType(typeof(Release))]
    [CmdLetTag(CmdLetTag.GitHub,CmdLetTag.Reactive,CmdLetTag.RX)][PublicAPI]
    public class GetGitHubRelease : GitHubCmdlet{
        [Parameter(Mandatory = true)]
        public string Repository{ get; set; }
        
        protected override  Task ProcessRecordAsync(){
            return GitHubClient.Repository.GetForOrg(Organization, Repository)
                .SelectMany(repository => GitHubClient.Repository.Release.GetAll(repository.Id))
                .SelectMany(list => list)
                .HandleErrors(this,Repository)
                .WriteObject(this)
                .ToTask();            
        }
    }
}