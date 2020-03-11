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
        public static async Task<Version[]> GetLatestMinors(this  List<Lazy<INuGetResourceProvider>> providers, string source, string name,int? top=3,SwitchParameter includePrelease=default,SwitchParameter includedDelisted=default){
            var packageMetadata = providers.PackageMetadata(source, name,includedDelisted,includePrelease).Replay().RefCount();
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
            SwitchParameter includeDelisted=default, SwitchParameter includePrerelease=default){
            var metadatas = new SourceRepository(new PackageSource(source), providers)
                .GetResourceAsync<PackageMetadataResource>().ToObservable()
                .SelectMany(resource => resource
                    .GetMetadataAsync(name, includePrerelease, includeDelisted,new SourceCacheContext(), NullLogger.Instance,CancellationToken.None).ToObservable()
                    .SelectMany(enumerable => enumerable.ToArray())
                );
            return metadatas;
        }

        public static IObservable<(string Id,Version Version)> ToPackageObject(this IObservable<IPackageSearchMetadata> source){
            return source.Select(metadata => (metadata.Identity.Id, metadata.Identity.Version.Version));
        }

        public static IObservable<IPackageSearchMetadata> ListPackages(this List<Lazy<INuGetResourceProvider>> providers, string source, SwitchParameter includeDelisted=default,
            SwitchParameter allVersions=default, SwitchParameter includePrerelease=default, string searchTerm = null){
            var sourceRepository = new SourceRepository(new PackageSource(source), providers);
            return sourceRepository.GetResourceAsync<ListResource>().ToObservable()
                .Select(resource =>
                    
                    resource.ListAsync(searchTerm, includePrerelease, allVersions, includeDelisted, NullLogger.Instance, CancellationToken.None)
                        .ToObservable()).Concat()
                .Select(async => async.GetEnumeratorAsync().ToObservable()).Concat()
                .Where(metadata => metadata != null);
        }
    }
}