using System;
using System.Collections.Generic;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading;
using NuGet.Common;
using NuGet.Configuration;
using NuGet.Protocol.Core.Types;

namespace XpandPwsh.Cmdlets.Nuget{
    internal static class NugetExtensions{
        public static IObservable<(string Id, Version Version)> SearchPackages(
            this List<Lazy<INuGetResourceProvider>> providers, string source, string searchTerm = null){
            var sourceRepository = new SourceRepository(new PackageSource(source), providers);
            return sourceRepository.GetResourceAsync<PackageSearchResource>().ToObservable()
                .Select(resource =>
                    resource.SearchAsync(searchTerm, new SearchFilter(false), 0, 1, NullLogger.Instance,
                        CancellationToken.None)).Concat()
                .SelectMany(metadatas => metadatas)
                .Select(metadata => (metadata.Identity.Id, metadata.Identity.Version.Version));


        }

        public static IObservable<(string Id, Version Version)> ListPackages(this List<Lazy<INuGetResourceProvider>> providers, string source,string searchTerm=null){
            var sourceRepository = new SourceRepository(new PackageSource(source), providers);
            return sourceRepository.GetResourceAsync<ListResource>().ToObservable()
                .Select(resource =>
                    resource.ListAsync(searchTerm, false, false, false, NullLogger.Instance, CancellationToken.None)
                        .ToObservable()).Concat()
                .Select(async => async.GetEnumeratorAsync().ToObservable()).Concat()
                .Where(metadata => metadata != null)
                .Select(metadata => (metadata.Identity.Id,metadata.Identity.Version.Version));
        }
    }
}