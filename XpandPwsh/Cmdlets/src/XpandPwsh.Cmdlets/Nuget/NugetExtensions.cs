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
using NuGet.Protocol.Core.Types;

namespace XpandPwsh.Cmdlets.Nuget{
    public static class NugetExtensions{
        public static async Task<Version[]> GetLatestMinors(this List<Lazy<INuGetResourceProvider>> providers,
            string source, string name, int? top = 3, SwitchParameter includePrerelease = default,
            SwitchParameter originalVersion = default,SwitchParameter includeUnlisted = default){
            var packageMetadata = providers.PackageMetadata(source, name,includeUnlisted,includePrerelease).Replay().RefCount();
            await packageMetadata;
            var versions = packageMetadata.ToEnumerable().GroupBy(metadata => {
                    var version = metadata.Identity.Version.Version;
                    return (version.Major, version.Minor);
                })
                .SelectMany(_ => _.OrderByDescending(metadata => metadata.Identity.Version.Version)
                    .Take(1).Select(metadata => metadata.Identity.Version.Version));
            if (top.HasValue){
                versions = versions.Take(top.Value);
            }

            return versions.ToArray();
        }

        public static IObservable<IPackageSearchMetadata> PackageMetadata(
            this List<Lazy<INuGetResourceProvider>> providers, string source, string name,
            SwitchParameter includeUnlisted=default, SwitchParameter includePrerelease=default) 
            => new SourceRepository(new PackageSource(source), providers)
                .GetResourceAsync<PackageMetadataResource>().ToObservable()
                .SelectMany(resource => resource
                    .GetMetadataAsync(name, includePrerelease, includeUnlisted,new SourceCacheContext(), NullLogger.Instance,CancellationToken.None).ToObservable()
                    .SelectMany(enumerable => enumerable.ToArray())
                );

        public static IObservable<(string Id,Version Version)> ToPackageObject(this IObservable<IPackageSearchMetadata> source) 
            => source.Select(metadata => (metadata.Identity.Id, metadata.Identity.Version.Version));

        public static IObservable<IPackageSearchMetadata> ListXpandPackages(this List<Lazy<INuGetResourceProvider>> providers, string xpandFeed, string nugetFeed){
            var labPackages =xpandFeed!=null? providers.ListPackages(xpandFeed, searchTerm: "Xpand"):Observable.Empty<IPackageSearchMetadata>();
            var nugetOrgPackages = nugetFeed!=null?providers.ListPackages(nugetFeed, searchTerm: "Xpand"):Observable.Empty<IPackageSearchMetadata>();
            return labPackages
                .Merge(nugetOrgPackages)
                .Distinct(metadata => metadata.Identity.Id)
                .Where(metadata => metadata.Authors == "eXpandFramework");
        }
        public static IObservable<IPackageSearchMetadata> ListPackages(this List<Lazy<INuGetResourceProvider>> providers, string source, SwitchParameter includeUnlisted=default,
            SwitchParameter allVersions=default, SwitchParameter includePrerelease=default, string searchTerm = null){
            var sourceRepository = new SourceRepository(new PackageSource(source), providers);
            return sourceRepository.GetResourceAsync<ListResource>().ToObservable()
                .Select(resource =>
                    
                    resource.ListAsync(searchTerm, includePrerelease, allVersions, includeUnlisted, NullLogger.Instance, CancellationToken.None)
                        .ToObservable()).Concat()
                .Select(async => async.GetEnumeratorAsync().ToObservable()).Concat()
                .Where(metadata => metadata != null&&metadata.IsListed==!includeUnlisted);
        }
    }
}