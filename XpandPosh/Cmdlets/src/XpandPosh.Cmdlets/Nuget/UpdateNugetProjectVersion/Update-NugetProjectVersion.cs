using System;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Subjects;
using System.Reactive.Threading.Tasks;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using Octokit;
using XpandPosh.Cmdlets.GitHub;
using XpandPosh.CmdLets;

namespace XpandPosh.Cmdlets.Nuget.UpdateNugetProjectVersion{
    [CmdletBinding(SupportsShouldProcess = true)]
    [Cmdlet(VerbsData.Update,"NugetProjectVersion",SupportsShouldProcess = true)]
    public class UpdateNugetProjectVersion:GitHubCmdlet,IParameter{
        [Parameter(Mandatory = true)]
        public string Repository{ get; set; } 
        [Parameter(Mandatory = true)]
        public string Branch{ get; set; } 
        [Parameter(Mandatory = true)]
        public string SourcePath{ get; set; }
        [Parameter(Mandatory=true)]
        public PSObject[] Packages{ get; set; }
        [Parameter]
        public SwitchParameter UpdateRevision{ get; set; }

        protected override async Task ProcessRecordAsync(){
            var lastTagedDate = (GitHubClient.Repository.GetForOrg(Organization, Repository)
                .Select(repository => GitHubClient.Repository
                    .LastTag(repository)
                    .Select(tag => GitHubClient.Repository.Commit.Get(repository.Id, tag.Commit.Sha))).Concat()
                .Concat()
                .Select(tag => tag.Commit.Committer.Date.AddSeconds(1)));
            var dateTimeOffset = await lastTagedDate;
            WriteVerbose($"lastTaggedDate={dateTimeOffset}");
            var commits =  GitHubClient.Commits(Organization, Repository,
                dateTimeOffset, Branch).Replay().RefCount();
            
            await commits.WriteVerboseObject(this,commit => commit.Commit.Message);
            var changedPackages = ExistingPackages(this).ToObservable()
                .WriteVerboseObject(this,_ => $"Existing: {_.name}, {_.nextVersion} ")
                .SelectMany(tuple => commits.Where(commit => commit.Files.Any(file => file.Filename.Contains(tuple.directory.Name))).Select(_=>tuple)).Distinct()
                .Replay().RefCount();
            await changedPackages.WriteVerboseObject(this);
            var subject = new Subject<string>();
            subject.WriteObject(this).Subscribe();
            var synchronizationContext = SynchronizationContext.Current;

            await changedPackages.SelectMany(tuple => GitHubClient.Repository
                    .GetForOrg(Organization, Repository)
                    .SelectMany(_ => CreateTagReference(this, GitHubClient, _, tuple, subject,synchronizationContext))
                    .Select(tag => tuple))
                .Select(UpdateAssemblyInfo)
                .HandleErrors(this)
                .WriteObject(this)
                .ToTask();
        }

        private string UpdateAssemblyInfo((string name, string nextVersion, DirectoryInfo directory) info){
            if (ShouldProcess($"Update {info.name} to version {info.nextVersion}")){
                var directoryName = info.directory.FullName;
                var path = $@"{directoryName}\Properties\AssemblyInfo.cs";
                var text = File.ReadAllText(path);
                text = Regex.Replace(text, @"Version\(""([^""]*)", $"Version(\"{info.nextVersion}");
                File.WriteAllText(path, text);
                return $"{info.name} version raised to {info.nextVersion} ";
            }

            return null;
        }


        private IObservable<Reference> CreateTagReference(IParameter parameter, GitHubClient appClient,
            Repository repository, (string name, string nextVersion, DirectoryInfo directory) tuple,
            IObserver<string> observer, SynchronizationContext synchronizationContext){
            observer.OnNext($"Lookup {tuple.name} heads");
            return appClient.Git.Reference.Get(repository.Id, $"heads/{parameter.Branch}")
                .ToObservable()
                .ObserveOn(synchronizationContext)
                .SelectMany(reference => {
                    var tag = $"{tuple.directory.Name}_{tuple.nextVersion}";
                    var description = $"Creating {tag} tag on repo {repository.Name}";
                    if (ShouldProcess(description)){
                        observer.OnNext(description);
                        return appClient.Git.Reference.Create(repository.Id,new NewReference($@"refs/tags/{tag}",reference.Object.Sha))
                            .ToObservable().Catch<Reference, ApiValidationException>(ex =>
                                ex.ApiError.Message=="Reference already exists"? Observable.Return<Reference>(null): Observable.Throw<Reference>(ex));
                    }

                    return Observable.Return(default(Reference));

                });
        }

        private static (string name, string nextVersion, DirectoryInfo directory)[] ExistingPackages(IParameter parameter){
            var packageArgs = parameter.Packages.Select(_ => (name: $"{_.Properties["Id"].Value}",
                nextVersion: $"{_.Properties["nextVersion"].Value}", directory: (DirectoryInfo) null)).ToArray();

            var existingPackages = Directory.GetFiles(parameter.SourcePath, "*.csproj", SearchOption.AllDirectories)
                .Where(s => packageArgs.Select(_ => _.name).Any(s.Contains)).ToArray()
                .Select(s => {
                    var valueTuple = packageArgs.First(_ => _.name == Path.GetFileNameWithoutExtension(s));
                    valueTuple.directory = new DirectoryInfo($"{Path.GetDirectoryName(s)}");
                    return valueTuple;
                }).ToArray();

            return existingPackages;
        }
    }

    public interface IParameter{
        PSObject[] Packages{ get; set; }
        string Owner{ get; set; }
        string Organization{ get; set; }
        string Repository{ get; set; }
        string Branch{ get; set; }
        string Pass{ get; set; }
        string SourcePath{ get; set; }
    }

}