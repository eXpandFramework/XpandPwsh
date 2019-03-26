using System;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Net;
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
                .WriteVerboseObject(this,_ => $"Existing: {_.name}, {_.version} ")
                .SelectMany(tuple => commits.Where(commit => commit.Files.Any(file => file.Filename.Contains(tuple.directory.Name))).Select(_=>tuple)).Distinct()
                .Publish().RefCount();

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

        internal async Task Test(){
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
            Packages = PsObjects();
            await ProcessRecordAsync();
        }

        private string UpdateAssemblyInfo((string name, string version, DirectoryInfo directory) info){
            var newVersion = GetVersion(info);
            if (newVersion.ToString() == info.version){
                return $"{info.name} will not be updated";
            }

            if (ShouldProcess($"Update {info.name} to version {newVersion}")){
                var directoryName = info.directory.FullName;
                var path = $@"{directoryName}\Properties\AssemblyInfo.cs";
                var text = File.ReadAllText(path);
                text = Regex.Replace(text, @"Version\(""([^""]*)", $"Version(\"{newVersion}");
                File.WriteAllText(path, text);
                return $"{info.name} version raised from {info.version} to {newVersion} ";
            }

            return null;
        }


        private IObservable<Reference> CreateTagReference(IParameter parameter, GitHubClient appClient,
            Repository repository, (string name, string version, DirectoryInfo directory) tuple,
            IObserver<string> observer, SynchronizationContext synchronizationContext){
            observer.OnNext($"Lookup {tuple.name} heads");
            return appClient.Git.Reference.Get(repository.Id, $"heads/{parameter.Branch}")
                .ToObservable()
                .ObserveOn(synchronizationContext)
                .SelectMany(reference => {
                    var tag = $"{tuple.directory.Name}_{GetVersion(tuple)}";
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
        private static Version GetVersion((string name, string version, DirectoryInfo directory) info){
            var directoryName = info.directory.FullName;
            var version = new Version(info.version);
            var path = $@"{directoryName}\Properties\AssemblyInfo.cs";
            var text = File.ReadAllText(path);
            var regex = new Regex(@"Version\(""([^""]*)""");
            var newVersion = new Version(version.Major, version.Minor, version.Build, version.Revision + 1);
            var fileVersion = new Version(regex.Match(text).Groups[1].Value);
            if (fileVersion.Build != version.Build){
                newVersion = new Version(fileVersion.Major, fileVersion.Minor, fileVersion.Build, fileVersion.Revision );
            }

            return newVersion;
        }

        private static (string name, string version, DirectoryInfo directory)[] ExistingPackages(IParameter parameter){
            var packageArgs = parameter.Packages.Select(_ => (name: $"{_.Properties["Name"].Value}", version: $"{_.Properties["Version"].Value}", directory: (DirectoryInfo) null)).ToArray();

            var existingPackages = Directory.GetFiles(parameter.SourcePath, "*.csproj", SearchOption.AllDirectories)
                .Where(s => packageArgs.Select(_ => _.name).Any(s.Contains)).ToArray()
                .Select(s => {
                    var valueTuple = packageArgs.First(_ => _.name == Path.GetFileNameWithoutExtension(s));
                    valueTuple.directory = new DirectoryInfo($"{Path.GetDirectoryName(s)}");
                    return valueTuple;
                }).ToArray();

            return existingPackages;
        }


        private static PSObject[] PsObjects(){
            return new[]{PSObject.AsPSObject(new{Name = "Xpand.XAF.Modules.ModelViewInheritance", Version = "1.0.8"})};
        }
    }

    static class Updater{
        public static IObservable<string> Update(this IParameter parameter){
            

            return Observable.Create<string>(observer => {
                var appClient = new GitHubClient(new ProductHeaderValue(parameter.Organization)){
                    Credentials = new Credentials(parameter.Owner, parameter.Pass)
                };

                var commits = (appClient.Repository.GetForOrg(parameter.Organization, parameter.Repository)
                        .Select(repository => appClient.Repository
                            .LastTag(repository)
                            .Select(tag => appClient.Repository.Commit.Get(repository.Id, tag.Commit.Sha))).Concat()
                        .Concat()
                        .Select(tag => tag.Commit.Committer.Date.AddSeconds(1)))
                    .Do(datetime => observer.OnNext($"lastTaggedDate={datetime}"))
                    .SelectMany(lastTaggedDate => appClient.Commits(parameter.Organization, parameter.Repository,
                        lastTaggedDate, parameter.Branch)).Publish().RefCount();

                var changedPackages = ExistingPackages(parameter).ToObservable()
                    .SelectMany(tuple => commits.Where(commit => commit.Files.Any(file => file.Filename.Contains(tuple.directory.Name))).Select(_=>tuple)).Distinct()
                    .Publish().RefCount();

                return changedPackages.SelectMany(tuple => appClient.Repository
                        .GetForOrg(parameter.Organization, parameter.Repository)
                        .SelectMany(_ => CreateTagReference(parameter, appClient, _, tuple,observer))
                        .Select(tag => tuple))
                    .Select(UpdateAssemblyInfo)
                    .Subscribe(observer);
            });
        }

        private static string UpdateAssemblyInfo((string name, string version, DirectoryInfo directory) info){
            var newVersion = GetVersion(info);
            var directoryName = info.directory.FullName;
            var path = $@"{directoryName}\Properties\AssemblyInfo.cs";
            var text = File.ReadAllText(path);
            text = Regex.Replace(text, @"Version\(""([^""]*)", $"Version(\"{newVersion}");
            File.WriteAllText(path, text);
            return $"{info.name} version raised from {info.version} to {newVersion} ";
        }

        private static Version GetVersion((string name, string version, DirectoryInfo directory) info){
            var directoryName = info.directory.FullName;
            var version = new Version(info.version);
            var path = $@"{directoryName}\Properties\AssemblyInfo.cs";
            var text = File.ReadAllText(path);
            var regex = new Regex(@"Version\(""([^""]*)""");
            var newVersion = new Version(version.Major, version.Minor, version.Build, version.Revision + 1);
            var fileVersion = new Version(regex.Match(text).Groups[1].Value);
            if (fileVersion.Build != version.Build){
                newVersion = new Version(fileVersion.Major, fileVersion.Minor, fileVersion.Build, fileVersion.Revision );
            }

            return newVersion;
        }

        private static (string name, string version, DirectoryInfo directory)[] ExistingPackages(IParameter parameter){
            var packageArgs = parameter.Packages.Select(_ => (name: $"{_.Properties["Name"].Value}", version: $"{_.Properties["Version"].Value}", directory: (DirectoryInfo) null)).ToArray();

            var existingPackages = Directory.GetFiles(parameter.SourcePath, "*.csproj", SearchOption.AllDirectories)
                .Where(s => packageArgs.Select(_ => _.name).Any(s.Contains)).ToArray()
                .Select(s => {
                    var valueTuple = packageArgs.First(_ => _.name == Path.GetFileNameWithoutExtension(s));
                    valueTuple.directory = new DirectoryInfo($"{Path.GetDirectoryName(s)}");
                    return valueTuple;
                }).ToArray();

            return existingPackages;
        }

        private static IObservable<Reference> CreateTagReference(IParameter parameter, GitHubClient appClient,
            Repository repository, (string name, string version, DirectoryInfo directory) tuple,
            IObserver<string> observer){
            observer.OnNext($"Lookup {tuple.name} heads");
            return appClient.Git.Reference.Get(repository.Id, $"heads/{parameter.Branch}")
                .ToObservable().SelectMany(reference => {
                    var tag = $"{tuple.directory.Name}_{GetVersion(tuple)}";
                    observer.OnNext($"Tagging {repository.Name} with {tag}");
                    return appClient.Git.Reference.Create(repository.Id,new NewReference($@"refs/tags/{tag}",reference.Object.Sha))
                        .ToObservable().Catch<Reference, ApiValidationException>(ex =>
                            ex.ApiError.Message=="Reference already exists"? Observable.Return<Reference>(null): Observable.Throw<Reference>(ex));

                });
        }

    }
    public interface IParameter{
        PSObject[] Packages{ get; set; }
        string GitHubApp{ get; set; }
        string Owner{ get; set; }
        string Organization{ get; set; }
        string Repository{ get; set; }
        string Branch{ get; set; }
        string Pass{ get; set; }
        string SourcePath{ get; set; }
    }

}