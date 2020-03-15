using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading;
using System.Threading.Tasks;
using JetBrains.Annotations;
using NuGet.Common;
using NuGet.Configuration;
using NuGet.Frameworks;
using NuGet.Protocol.Core.Types;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.Nuget{
    [Cmdlet(VerbsCommon.Get, "NugetPackage")]
    [CmdletBinding]
    [CmdLetTag(CmdLetTag.Nuget,CmdLetTag.Reactive,CmdLetTag.RX)][PublicAPI]
    public class GetNugetPackage : NugetCmdlet{
        [Parameter(ValueFromPipeline = true,Position = 0)]
        public string Name{ get; set; }
        [Parameter( Position = 2)]
        public string[] Source{ get; set; }

        [Parameter(Position = 1)]
        public string OutputFolder{ get; set; } = $@"{Path.GetTempPath()}\{nameof(GetNugetPackage)}";
        [Parameter]
        public SwitchParameter AllVersions{ get; set; }
        [Parameter]
        public string[] Versions{ get; set; }
        [Parameter]
        public SwitchParameter AllFiles{ get; set; }
        [Parameter]
        public NugetPackageResultType ResultType{ get; set; }
        protected override Task BeginProcessingAsync(){
            if (OutputFolder == null){
                OutputFolder = Path.Combine(Path.GetTempPath(), Name);
            }

            if (Source == null){
                Source = new[]{"https://api.nuget.org/v3/index.json"};
            }
            return base.BeginProcessingAsync();
        }

        protected override Task ProcessRecordAsync(){
            return GetDownloadResults()
                .Select(result => {
                    switch (ResultType){
                        case NugetPackageResultType.Default:
                            return NugetPackageAssemblies(result).ToObservable().OfType<object>();
                        case NugetPackageResultType.DownloadResults:
                            return Observable.Return(result).OfType<object>();
                        case NugetPackageResultType.NuSpecFile:
                            return Observable.Return(new FileInfo(result.PackageReader.GetNuspecFile()));
                        case NugetPackageResultType.NupkgFile:{
                            var directoryName = $"{Path.GetDirectoryName(result.PackageReader.GetNuspecFile())}";
                            return Observable.Return(Directory.GetFiles(directoryName,"*.nupkg",SearchOption.TopDirectoryOnly).First());
                        }
                    }

                    return Observable.Throw<object>(new NotImplementedException(ResultType.ToString()));
                })
                .Concat()
                .DefaultIfEmpty()
                .HandleErrors(this,Name??OutputFolder)
                .WriteObject(this)
                .ToTask();
        }

        private IEnumerable<NugetPackageAssembly> NugetPackageAssemblies(DownloadResourceResult result){
            return result.PackageReader.GetLibItems().SelectMany(group => group.Items
                    .Where(s => AllFiles || Path.GetExtension(s) == ".dll")
                    .Select(s => {
                        var nuspecReader = result.PackageReader.NuspecReader;
                        var identity = nuspecReader.GetIdentity();
                        return new NugetPackageAssembly{
                                Package = identity.Id,
                                Version = identity.Version.Version.ToString(),
                                DotNetFramework = group.TargetFramework.GetDotNetFrameworkName(DefaultFrameworkNameProvider.Instance),
                                File = $@"{s.Replace(@"/", @"\")}"
                            };
                    }));
        }

        private IObservable<DownloadResourceResult> GetDownloadResults(){
            var sourceSearchMetadatas = PackageSourceSearchMetadatas(Source.First()).Take(1);
            var packageSourceSearchMetadatas = sourceSearchMetadatas.ToObservable().Replay().RefCount();
            var downloadContext = new PackageDownloadContext(new SourceCacheContext());
            var providers = new List<Lazy<INuGetResourceProvider>>();
            providers.AddRange(Repository.Provider.GetCoreV3());

            var downloads = Source.ToObservable().Select(s => {
                    var repository = new SourceRepository(new PackageSource(s), providers);
                    return repository.GetResourceAsync<DownloadResource>().ToObservable()
                        .Select(resource => (resource, repository));
                }).Concat()
                .Replay().RefCount();
            return packageSourceSearchMetadatas
                .Select(metadata => downloads
                    .Select(tuple => tuple.resource.GetDownloadResourceResultAsync(metadata.Identity,
                        downloadContext, OutputFolder, NullLogger.Instance, CancellationToken.None)))
                .Concat().Concat()
                .Where(result => result.Status == DownloadResourceResultStatus.Available)
                .HandleErrors(this, Name);        }

        private Collection<IPackageSearchMetadata> PackageSourceSearchMetadatas(string source,int index=0){
            
            string allVersions = $"-{nameof(AllVersions)} {AllVersions}";
            if (!AllVersions){
                allVersions = null;
            }
            string sources = $"-{nameof(Source)} '{Source[index]}'";
            index++;
            string versions = null;
            if (Versions != null){
                versions = $"-{nameof(Versions)} @({string.Join(",", Versions.Select(s => $"'{s}'"))})";
            }

            string name=$"-{nameof(Name)} {Name}";
            if (Name == null){
                name = null;
            }

            var cmdletName = CmdletExtensions.GetCmdletName<GetNugetPackageSearchMetadata>();
            var script = $"{cmdletName} {sources} {allVersions} {name} {versions} -{nameof(GetNugetPackageSearchMetadata.IncludeDelisted)}";
            var sourceSearchMetadatas = this.Invoke<IPackageSearchMetadata>(script);
            if (sourceSearchMetadatas == null!||!sourceSearchMetadatas.Any()){
                if (index==Source.Length){
                    throw new ItemNotFoundException($"{Name}---{script}");
                }

                return PackageSourceSearchMetadatas(source, index);
            }
            return sourceSearchMetadatas;
        }
    }

    public enum NugetPackageResultType{
        Default,
        DownloadResults,
        NuSpecFile,
        NupkgFile
    }

    public class NugetPackageAssembly:INugetPackageAssembly{
        public string Package{ get; set; }
        public string Version{ get; set; }
        public string DotNetFramework{ get; set; }
        public string File{ get; set; }
    }
    public interface INugetPackageAssembly{
        string Package{ get; set; }
        string Version{ get; set; }
        string DotNetFramework{ get; set; }
        string File{ get; set; }
    }
}

