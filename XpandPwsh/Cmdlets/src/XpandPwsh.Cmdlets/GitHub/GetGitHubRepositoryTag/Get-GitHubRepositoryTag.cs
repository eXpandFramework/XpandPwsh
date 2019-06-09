using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using Octokit;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.GitHub.GetGitHubRepositoryTag{
    [CmdletBinding()]
    [Cmdlet(VerbsCommon.Get, "GitHubRepositoryTag")]
    [OutputType(typeof(GitTag))]
    public class GetGitHubRepositoryTag : GitHubCmdlet{
        [Parameter(Mandatory = true,ValueFromPipeline = true)]
        public string Repository{ get; set; }
        [Parameter]
        public SwitchParameter Latest{ get; set; }
        protected override  Task ProcessRecordAsync(){
            var repositoriesClient = GitHubClient.Repository;
            return repositoriesClient.GetForOrg(Organization, Repository)
                .SelectMany(repository => repositoriesClient
                    .GetAllTags(repository.Id))
                .SelectMany(list => list)
                .HandleErrors(this,Repository)
                .WriteObject(this)
                .ToTask();
        }
    }
}