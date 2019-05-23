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
using ImpromptuInterface;
using NuGet.Common;
using NuGet.Configuration;
using NuGet.Frameworks;
using NuGet.Protocol;
using NuGet.Protocol.Core.Types;
using XpandPosh.CmdLets;

namespace XpandPosh.Cmdlets.Nuget.GetNugetPackage{
    [Cmdlet(VerbsCommon.Get, "NugetPackage")]
    [OutputType(typeof(INugetPackageAssembly))]
    [CmdletBinding]
    public class GetNugetPackage : NugetCmdlet{
        [Parameter(ValueFromPipeline = true,Position = 0,Mandatory = true)]
        public string Name{ get; set; }
        [Parameter( Position = 2)]
        public string Source{ get; set; }
        [Parameter( Position = 1)]
        public string OutputFolder{ get; set; } 
        [Parameter]
        public SwitchParameter AllVersions{ get; set; }
        [Parameter]
        public string[] Versions{ get; set; }
        [Parameter]
        public SwitchParameter AllFiles{ get; set; }

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
                .SelectMany(NugetPackageAssemblies)
                .DefaultIfEmpty()
                .HandleErrors(this,Name)
                .WriteObject(this)
                .ToTask();
        }

        private IEnumerable<INugetPackageAssembly> NugetPackageAssemblies(DownloadResourceResult result){
            return result.PackageReader.GetLibItems().SelectMany(group => group.Items
                    .Where(s => AllFiles || Path.GetExtension(s) == ".dll")
                    .Select(s => {
                        var identity = result.PackageReader.NuspecReader.GetIdentity();
                        return new{
                                Package = identity.Id,
                                Version = identity.Version.Version.ToString(),
                                DotNetFramework = group.TargetFramework.GetDotNetFrameworkName(DefaultFrameworkNameProvider.Instance),
                                File = $@"{s.Replace(@"/", @"\")}"
                            }
                            .ActLike<INugetPackageAssembly>();
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
                .SelectMany(metadata => {
                    return downloads.FirstAsync(tuple => tuple.Item2.PackageSource.Source == Source)
                        .SelectMany(tuple => tuple.Item1.GetDownloadResourceResultAsync(metadata.Identity,
                            downloadContext, OutputFolder, NullLogger.Instance, CancellationToken.None));
                })
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

            var cmdletName = CmdletExtensions.GetCmdletName<GetNugetPackageSearchMetadata.GetNugetPackageSearchMetadata>();
            var script = $"{cmdletName} {sources} {allVersions} {name} {versions}";
            var sourceSearchMetadatas = this.Invoke<IPackageSearchMetadata>(script);
            return sourceSearchMetadatas;
        }
    }


}

