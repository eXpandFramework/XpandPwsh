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
using NuGet.Common;
using NuGet.Configuration;
using NuGet.Frameworks;
using NuGet.Protocol.Core.Types;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.Nuget{
    [Cmdlet(VerbsCommon.Get, "NugetPackage")]
    [CmdletBinding]
    public class GetNugetPackage : NugetCmdlet{
        [Parameter(ValueFromPipeline = true,Position = 0)]
        public string Name{ get; set; }
        [Parameter( Position = 2)]
        public string Source{ get; set; }

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
                Source = "https://api.nuget.org/v3/index.json";
            }
            return base.BeginProcessingAsync();
        }

        protected override  Task ProcessRecordAsync(){
            return GetDownloadResults()
                .SelectMany(result => ResultType == NugetPackageResultType.Default ? NugetPackageAssemblies(result).ToObservable().OfType<object>()
                        : Observable.Return(result).OfType<object>())
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
            var sourceSearchMetadatas = PackageSourceSearchMetadatas();
            var packageSourceSearchMetadatas = sourceSearchMetadatas.ToObservable().Replay().RefCount();
            var downloadContext = new PackageDownloadContext(new SourceCacheContext());
            var providers = new List<Lazy<INuGetResourceProvider>>();
            providers.AddRange(Repository.Provider.GetCoreV3());

            var sourceRepository = new SourceRepository(new PackageSource(Source), providers);

            var downloads = sourceRepository.GetResourceAsync<DownloadResource>().ToObservable()
                .Select(resource => (resource, sourceRepository))
                .Replay().RefCount();
            return packageSourceSearchMetadatas
                .SelectMany(metadata => downloads.FirstAsync(tuple => tuple.sourceRepository.PackageSource.Source == Source)
                    .SelectMany(tuple => tuple.resource.GetDownloadResourceResultAsync(metadata.Identity,
                        downloadContext, OutputFolder, NullLogger.Instance, CancellationToken.None)))
                .Where(result => result.Status == DownloadResourceResultStatus.Available)
                .HandleErrors(this, Name);        }

        private Collection<IPackageSearchMetadata> PackageSourceSearchMetadatas(){
            
            string allVersions = $"-{nameof(AllVersions)} {AllVersions}";
            if (!AllVersions){
                allVersions = null;
            }
            string sources = $"-{nameof(Source)} '{Source}'";
            string versions = null;
            if (Versions != null){
                versions = $"-{nameof(Versions)} @({string.Join(",", Versions.Select(s => $"'{s}'"))})";
            }

            string name=$"-{nameof(Name)} {Name}";
            if (Name == null){
                name = null;
            }

            var cmdletName = CmdletExtensions.GetCmdletName<GetNugetPackageSearchMetadata>();
            var script = $"{cmdletName} {sources} {allVersions} {name} {versions}";
            var sourceSearchMetadatas = this.Invoke<IPackageSearchMetadata>(script);
            return sourceSearchMetadatas;
        }
    }

    public enum NugetPackageResultType{
        Default,
        DownloadResults,
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

