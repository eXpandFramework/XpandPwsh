using System;
using System.Collections.Generic;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading;
using NuGet.Common;
using NuGet.Configuration;
using NuGet.Protocol.Core.Types;

namespace XpandPosh.Cmdlets.Nuget{
    internal static class NugetExtensions{
        public static IObservable<string> ListPackages(this List<Lazy<INuGetResourceProvider>> providers, string source,string searchTerm=null){
            var sourceRepository = new SourceRepository(new PackageSource(source), providers);
            return sourceRepository.GetResourceAsync<ListResource>().ToObservable()
                .Select(resource =>
                    resource.ListAsync(searchTerm, false, false, false, NullLogger.Instance, CancellationToken.None)
                        .ToObservable()).Concat()
                .Select(async => async.GetEnumeratorAsync().ToObservable()).Concat()
                .Where(metadata => metadata != null)
                .Select(metadata => metadata.Identity.Id);
        }
    }
}