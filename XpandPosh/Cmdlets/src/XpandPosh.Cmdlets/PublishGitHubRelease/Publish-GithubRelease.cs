using System;
using System.IO;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using Octokit;
using XpandPosh.CmdLets;

namespace XpandPosh.Cmdlets.PublishGitHubRelease{
    [CmdletBinding(SupportsShouldProcess = true)]
    [OutputType(typeof(Release))]
    [Cmdlet(VerbsData.Publish, "GitHubRelease",SupportsShouldProcess = true)]
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
            var repositoriesClient = NewGitHubClient().Repository;
            var repository = await repositoriesClient.GetForOrg(Organization, Repository);
            var release = await repositoriesClient.Release.GetAll(repository.Id).ToObservable().SelectMany(list => list).Where(_ => _.Name==ReleaseName)
                .IgnoreException<Release,NotFoundException>(this,ReleaseName).DefaultIfEmpty();
            if (release == null){
                WriteVerbose("Creating new release");
                var newRelease = new NewRelease(ReleaseName){Draft = Draft,Body = ReleaseNotes,Name = ReleaseName};
                release = await repositoriesClient.Release.Create(repository.Id, newRelease);
                WriteVerbose("Uploading assets");
                var mime = new MimeSharp.Mime();
                if (Files != null){
                    await Files.ToObservable()
                        .Do(file => WriteVerbose($"Uploading {file}"))
                        .SelectMany(file => Observable.Using(() => File.OpenRead(file), stream => {
                            var releaseAssetUpload = new ReleaseAssetUpload() {
                                FileName = file, ContentType = mime.Lookup(Path.GetFileName(file)), RawData = stream
                            };
                            return repositoriesClient.Release.UploadAsset(release, releaseAssetUpload).ToObservable();
                        }));
                }
                WriteObject(release);
                
            }
            else{
                throw new NotSupportedException($"Release {ReleaseName} exists");
            }
        }




    }
}