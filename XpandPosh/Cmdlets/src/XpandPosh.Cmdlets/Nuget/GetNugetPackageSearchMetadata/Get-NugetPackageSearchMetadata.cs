using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading;
using System.Threading.Tasks;
using NuGet.Common;
using NuGet.Configuration;
using NuGet.Protocol;
using NuGet.Protocol.Core.Types;

namespace XpandPosh.Cmdlets.Nuget.GetNugetPackageSearchMetadata{
    [Cmdlet(VerbsCommon.Get, "NugetPackageSearchMetadata")]
    [CmdletBinding()]
    public  class GetNugetPackageSearchMetadata : NugetCmdlet{
        [Parameter(Position = 0, ValueFromPipeline = true)]
        public string Name{ get; set; }

        [Parameter(Position = 1,Mandatory = true)]
        public string Source{ get; set; } 

        [Parameter]
        public SwitchParameter IncludePrerelease{ get; set; } = new SwitchParameter(false);

        [Parameter]
        public SwitchParameter IncludeUnlisted{ get; set; } = new SwitchParameter(false);

        [Parameter]
        public SwitchParameter AllVersions{ get; set; } = new SwitchParameter(false);

        [Parameter]
        public string[] Versions{ get; set; }


        protected override Task ProcessRecordAsync(){
            var providers = new List<Lazy<INuGetResourceProvider>>();
            providers.AddRange(Repository.Provider.GetCoreV3());
            return ListPackages(providers)
                .HandleErrors(this,Name)
                .Select(s => SelectPackages(s, providers))
                .Concat()
                .HandleErrors(this,Name)
                .WriteObject(this)
                .ToTask();
        }

        private IObservable<IPackageSearchMetadata> SelectPackages(string s, List<Lazy<INuGetResourceProvider>> providers){
            return PackageSourceSearchMetadatas(Source, s,providers)
                .Concat(Observable.Empty<IPackageSearchMetadata>());
        }

        private IObservable<string> ListPackages(List<Lazy<INuGetResourceProvider>> providers){
            if (Name != null) return Observable.Return(Name);

            var sourceRepository = new SourceRepository(new PackageSource(Source), providers);
            return sourceRepository.GetResourceAsync<ListResource>().ToObservable()
                .Select(resource =>
                    resource.ListAsync(null, false, false, false, NullLogger.Instance, CancellationToken.None)
                        .ToObservable())
                .Concat()
                .Select(async => async.GetEnumeratorAsync().ToObservable()).Concat()
                .Where(metadata => metadata!=null)
                .Select(metadata => metadata.Identity.Id);
        }

        private IObservable<IPackageSearchMetadata> PackageSourceSearchMetadatas(string source,string name,
            List<Lazy<INuGetResourceProvider>> providers){
            var metadatas = new SourceRepository(new PackageSource(source), providers)
                .GetResourceAsync<PackageMetadataResource>().ToObservable()
                .SelectMany(resource => resource
                    .GetMetadataAsync(name, IncludePrerelease, IncludeUnlisted, NullLogger.Instance,
                        CancellationToken.None).ToObservable())
                .Select(enumerable => enumerable.ToArray())
                .Select(searchMetadatas => searchMetadatas.ToObservable()).Concat();

            if (!AllVersions && Versions == null) return metadatas.FirstAsync();

            if (Versions != null)
                return metadatas.Where(metadata => {
                    var nuGetVersion = metadata.GetNuGetVersion().ToString();
                    return Versions.Contains(nuGetVersion);
                });
            return metadatas;
        }

    }
}