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
using XpandPosh.CmdLets;

namespace XpandPosh.Cmdlets.GetNugetPackageSearchMetadata{
    [Cmdlet(VerbsCommon.Get, "NugetPackageSearchMetadata")]
    [OutputType(typeof(IPackageSourceSearchMetadata))]
    [CmdletBinding()]
    public  class GetNugetPackageSearchMetadata : XpandCmdlet{
        [Parameter(Position = 0, ValueFromPipeline = true)]
        public string Name{ get; set; }

        [Parameter(Position = 1,Mandatory = true)]
        public string[] Sources{ get; set; } 

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
                .Select(s => PackageSourceSearchMetadatas(s, providers)).Concat()
                .HandleErrors(this,Name)
                .Distinct(new MetadataEqualityComparer())
                .WriteObject(this)
                .ToTask();
        }

        private IObservable<string> ListPackages(List<Lazy<INuGetResourceProvider>> providers){
            if (Name != null) return Observable.Return(Name);

            return Sources.ToObservable().SelectMany(source => {
                    var sourceRepository = new SourceRepository(new PackageSource(source), providers);
                    return sourceRepository.GetResourceAsync<ListResource>().ToObservable()
                        .Select(resource =>
                            resource.ListAsync(null, false, false, false, NullLogger.Instance, CancellationToken.None)
                                .ToObservable())
                        .Concat();
                })
                .SelectMany(async => async.GetEnumeratorAsync().ToObservable())
                .Where(metadata => metadata!=null)
                .Select(metadata => metadata.Identity.Id);
        }

        private IObservable<IPackageSourceSearchMetadata> PackageSourceSearchMetadatas(string name,
            List<Lazy<INuGetResourceProvider>> providers){
            var metadatas = Sources.ToObservable()
                .SelectMany(source => new SourceRepository(new PackageSource(source), providers)
                    .GetResourceAsync<PackageMetadataResource>().ToObservable()
                    .SelectMany(resource => resource
                        .GetMetadataAsync(name, IncludePrerelease, IncludeUnlisted, NullLogger.Instance,
                            CancellationToken.None).ToObservable()
                        .SelectMany(_ => _).Select(metadata => new PackageSourceSearchMetadata
                            {Source = source, Metadata = metadata})));
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