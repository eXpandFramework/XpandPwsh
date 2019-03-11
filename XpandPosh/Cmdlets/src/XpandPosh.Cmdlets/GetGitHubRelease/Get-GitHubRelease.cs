using System.Linq;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using Octokit;
using XpandPosh.CmdLets;

namespace XpandPosh.Cmdlets.GetGitHubRelease{
    [CmdletBinding()]
    [Cmdlet(VerbsCommon.Get, "GitHubRelease")]
    [OutputType(typeof(Release))]
    public class GetGitHubRelease : GitHubCmdlet{
        [Parameter(Mandatory = true)]
        public string Repository{ get; set; }
        
        protected override  Task ProcessRecordAsync(){
            var appClient = NewGitHubClient();
            return appClient.Repository.GetAllForOrg(Organization).ToObservable()
                .Select(list => list.First(repository => repository.Name == Repository))
                .SelectMany(repository => appClient.Repository.Release.GetAll(repository.Id))
                .SelectMany(list => list)
                .HandleErrors(this,Repository)
                .WriteObject(this)
                .ToTask();            
        }
    }
}