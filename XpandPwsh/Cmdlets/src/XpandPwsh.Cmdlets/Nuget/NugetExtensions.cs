using System;
using System.Collections.Generic;
using System.Linq;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading;
using NuGet.Common;
using NuGet.Configuration;
using NuGet.Protocol.Core.Types;

namespace XpandPwsh.Cmdlets.Nuget{
    internal static class NugetExtensions{
        public static IObservable<IPackageSearchMetadata> PackageMetadata(this  List<Lazy<INuGetResourceProvider>> providers,string source,string name){
            var metadatas = new SourceRepository(new PackageSource(source), providers)
                .GetResourceAsync<PackageMetadataResource>().ToObservable()
                .SelectMany(resource => resource
                    .GetMetadataAsync(name, false, false, NullLogger.Instance,CancellationToken.None).ToObservable()
                    .SelectMany(enumerable => enumerable.ToArray())
                );
            return metadatas;
        }

        public static IObservable<(string Id,Version Version)> ToPackageObject(this IObservable<IPackageSearchMetadata> source){
            return source.Select(metadata => (metadata.Identity.Id, metadata.Identity.Version.Version));
        }

        public static IObservable<IPackageSearchMetadata> ListPackages(this List<Lazy<INuGetResourceProvider>> providers, string source,string searchTerm=null){
            var sourceRepository = new SourceRepository(new PackageSource(source), providers);
            return sourceRepository.GetResourceAsync<ListResource>().ToObservable()
                .Select(resource =>
                    resource.ListAsync(searchTerm, false, false, false, NullLogger.Instance, CancellationToken.None)
                        .ToObservable()).Concat()
                .Select(async => async.GetEnumeratorAsync().ToObservable()).Concat()
                .Where(metadata => metadata != null);
        }
    }
}