using System;
using System.IO;
using System.Management.Automation;
using System.Reactive.Concurrency;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using JetBrains.Annotations;
using Octokit;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.GitHub.PublishGitHubRelease{
    [CmdletBinding(SupportsShouldProcess = true)]
    [OutputType(typeof(Release))]
    [Cmdlet(VerbsData.Publish, "GitHubRelease",SupportsShouldProcess = true)]
    [CmdLetTag(CmdLetTag.GitHub,CmdLetTag.Reactive,CmdLetTag.RX)][PublicAPI]
    public class PublishGitHubRelease : GitHubCmdlet{
        
        [Parameter(Mandatory = true)]
        public string Repository{ get; set; }
        [Parameter(Mandatory = true)]
        public string ReleaseName{ get; set; }
        [Parameter]
        public string ReleaseNotes{ get; set; }
        [Parameter]
        public string[] Files{ get; set; }
        [Parameter]
        public SwitchParameter Draft{ get; set; } 

        protected override async Task ProcessRecordAsync(){
            var repositoriesClient = GitHubClient.Repository;
            var repository = await repositoriesClient.GetForOrg(Organization, Repository);
            var release = await repositoriesClient.Release.GetAll(repository.Id).ToObservable().SelectMany(list => list).Where(_ => _.Name==ReleaseName)
                .IgnoreException<Release,NotFoundException>(this,ReleaseName).DefaultIfEmpty();
            if (release == null){
                WriteVerbose("Creating new release");
                var newRelease = new NewRelease(ReleaseName){Draft = Draft,Body = ReleaseNotes,Name = ReleaseName};
                release = await repositoriesClient.Release.Create(repository.Id, newRelease);
                WriteVerbose("Uploading assets");
                
                if (Files != null){
                    await Files.ToObservable(ImmediateScheduler.Instance)
                        .Do(file => WriteVerbose($"Uploading {file}"))
                        .Select(file => Observable.Using(() => File.OpenRead(file), stream => {
                            var fileName = Path.GetFileName(file);
                            var releaseAssetUpload = new ReleaseAssetUpload() {
                                FileName = fileName, ContentType = MimeSharp.Mime.Lookup(fileName), RawData = stream
                            };
                            return Observable.FromAsync(() => repositoriesClient.Release.UploadAsset(release, releaseAssetUpload));
                        })).Concat();
                }
                WriteObject(release);
                
            }
            else{
                throw new NotSupportedException($"Release {ReleaseName} exists");
            }
        }




    }
}