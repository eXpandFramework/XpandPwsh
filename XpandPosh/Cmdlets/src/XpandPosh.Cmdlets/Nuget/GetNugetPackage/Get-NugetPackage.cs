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
using NuGet.Packaging;
using NuGet.Protocol;
using NuGet.Protocol.Core.Types;
using XpandPosh.Cmdlets.Nuget.GetNugetPackageSearchMetadata;
using XpandPosh.CmdLets;

namespace XpandPosh.Cmdlets.Nuget.GetNugetPackage{
    [Cmdlet(VerbsCommon.Get, "NugetPackage")]
    [OutputType(typeof(INugetPackageAssembly))]
    [CmdletBinding]
    public class GetNugetPackage : NugetCmdlet{
        [Parameter(ValueFromPipeline = true)]
        public string Name{ get; set; } 

        [Parameter(Mandatory = true, Position = 2)]
        public string[] Sources{ get; set; } 

        [Parameter(Mandatory =true, Position = 1)]
        public string OutputFolder{ get; set; } 
        [Parameter]
        public SwitchParameter AllVersions{ get; set; }

        [Parameter]
        public string[] Versions{ get; set; } 

        [Parameter]
        public SwitchParameter AllFiles{ get; set; }

        protected override  Task ProcessRecordAsync(){
            return GetDownloadResults()
                .SelectMany(NugetPackageAssemblies)
                .DefaultIfEmpty()
                .HandleErrors(this,Name)
                .WriteObject(this)
                .ToTask();
        }

        private IEnumerable<INugetPackageAssembly> NugetPackageAssemblies(DownloadResourceResult result){
            var resultPackageReader = (PackageFolderReader) result.PackageReader;
            var directoryInfo = new DirectoryInfo($"{Path.GetDirectoryName(resultPackageReader.GetNuspecFile())}");
            return resultPackageReader.GetLibItems().SelectMany(group =>
                group.Items
                    .Where(s => AllFiles || Path.GetExtension(s) == ".dll")
                    .Select(s => new{
                        Package = directoryInfo.Parent?.Name,
                        Version = directoryInfo.Name,
                        DotNetFramework = group.TargetFramework.GetDotNetFrameworkName(DefaultFrameworkNameProvider.Instance),
                        File = $@"{s.Replace(@"/", @"\")}"
                    }.ActLike<INugetPackageAssembly>()));
        }

        private IObservable<DownloadResourceResult> GetDownloadResults(){
            var sourceSearchMetadatas = PackageSourceSearchMetadatas();
            var packageSourceSearchMetadatas = sourceSearchMetadatas.ToObservable().Replay().RefCount();
            var downloadContext = new PackageDownloadContext(new SourceCacheContext());
            var providers = new List<Lazy<INuGetResourceProvider>>();
            providers.AddRange(Repository.Provider.GetCoreV3()); 
            
            var downloads = packageSourceSearchMetadatas.Select(metadata => metadata.Source).Distinct()
                .Select(s => new SourceRepository(new PackageSource(s), providers))
                .SelectMany(repository => repository.GetResourceAsync<DownloadResource>().ToObservable().Select(resource => (resource,repository)))
                .Replay().RefCount();
            return packageSourceSearchMetadatas
                .SelectMany(metadata => {
                    return downloads.FirstAsync(tuple => tuple.Item2.PackageSource.Source == metadata.Source)
                        .SelectMany(tuple => tuple.Item1.GetDownloadResourceResultAsync(metadata.Metadata.Identity,
                            downloadContext, OutputFolder, NullLogger.Instance, CancellationToken.None));
                })
                .Where(result => result.Status == DownloadResourceResultStatus.Available)
                .HandleErrors(this, Name);
        }

        private Collection<IPackageSourceSearchMetadata> PackageSourceSearchMetadatas(){
            
            string allVersions = $"-{nameof(AllVersions)} {AllVersions}";
            if (!AllVersions){
                allVersions = null;
            }
            string sources = $"-{nameof(Sources)} @({string.Join(",", Sources.Select(s => $"'{s}'"))})";
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
            var sourceSearchMetadatas = this.Invoke<IPackageSourceSearchMetadata>(script);
            return sourceSearchMetadatas;
        }
    }


}

