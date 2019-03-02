using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading;
using NuGet.Common;
using NuGet.Configuration;
using NuGet.Protocol;
using NuGet.Protocol.Core.Types;
using NuGet.Versioning;

namespace XpandPosh.Cmdlets.GetNugetPackageSearchMetadata{
     public interface IPackageSourceSearchMetadata{
         string Source{ get; }
         IPackageSearchMetadata Metadata{ get; }
     }

     class PackageSourceSearchMetadata:IPackageSourceSearchMetadata{
         public PackageSourceSearchMetadata(string source, IPackageSearchMetadata metadata){
             Source = source;
             Metadata = metadata;
         }

         public string Source{ get;  }
         public IPackageSearchMetadata Metadata{ get;  }
     }
     [Cmdlet(VerbsCommon.Get, "NugetPackageSearchMetadata")]
     [OutputType(typeof(IPackageSourceSearchMetadata))]
     [CmdletBinding]
     public class GetNugetPackageSearchMetadata : Cmdlet{
         [Parameter(Position = 0,ValueFromPipeline = true,Mandatory = true)]
         public string Name{ get; set; }

         [Parameter(Position = 1)]
         public string[] Sources{ get; set; } = {"https://nuget.devexpress.com/88luCgoeuPFTrDrTDcc6zKg22U2cVcTm3vdKCv88I7PHF9St6i/api"};
         [Parameter]
         public SwitchParameter IncludePrerelease{ get; set; } =new SwitchParameter(false);
         [Parameter]
         public SwitchParameter IncludeUnlisted{ get; set; } = new SwitchParameter(false);
         [Parameter]
         public SwitchParameter AllVersions{ get; set; } = new SwitchParameter(false);
         [Parameter]
         public string[] Versions{ get; set; }

         class MetadataEqualityComparer:IEqualityComparer<IPackageSourceSearchMetadata>{
             public bool Equals(IPackageSourceSearchMetadata x, IPackageSourceSearchMetadata y){
                 return x?.Metadata.Identity.Id == y?.Metadata.Identity.Id && GetNuGetVersion(x)?.Version == GetNuGetVersion(y)?.Version;
             }

             public int GetHashCode(IPackageSourceSearchMetadata obj){
                 return $"{obj.Metadata.Identity.Id}{GetNuGetVersion(obj).Version}".GetHashCode();
             }
         }
         protected override void ProcessRecord(){
             base.ProcessRecord();
             var providers = new List<Lazy<INuGetResourceProvider>>();
             providers.AddRange(Repository.Provider.GetCoreV3());
             var metadatas =ListPackages(providers)
                 .SelectMany(s => GetPackageSourceSearchMetadatas(s,providers)) 
                 .OnErrorResumeNext(Observable.Empty<IPackageSourceSearchMetadata>())
                 .ToEnumerable();
             WriteObject(metadatas, true);

         }

         private IObservable<string> ListPackages(List<Lazy<INuGetResourceProvider>> providers){
             if (Name != null){
                 return Observable.Return(Name);
             }

             return Sources.ToObservable().SelectMany(source => {
                     var sourceRepository = new SourceRepository(new PackageSource(source), providers);
                     return sourceRepository.GetResourceAsync<ListResource>().ToObservable()
                         .Select(resource => resource.ListAsync(null,false,false,false,NullLogger.Instance, CancellationToken.None).ToObservable())
                         .Merge();
                 })
                 .SelectMany(async => {
                     return Observable.Create<IPackageSearchMetadata>(observer =>{
                         var enumeratorAsync = async.GetEnumeratorAsync();
                         return enumeratorAsync.MoveNextAsync().ToObservable()
                             .Do(b => {
                                 if (b){
                                     observer.OnNext(enumeratorAsync.Current);
                                 }
                                 else{
                                     observer.OnCompleted();
                                 }
                             })
                             .Subscribe();
                         
                     });
                     
                 })
                 .Select(metadata => metadata.Identity.Id);
         }

         private IPackageSourceSearchMetadata[] GetPackageSourceSearchMetadatas(string name,
             List<Lazy<INuGetResourceProvider>> providers){
             var metadatas = Sources.SelectMany(source => {
                     var sourceRepository = new SourceRepository(new PackageSource(source), providers);
                     var packageMetadataResource = sourceRepository.GetResourceAsync<PackageMetadataResource>().Result;
                     return packageMetadataResource.GetMetadataAsync(name, IncludePrerelease, IncludeUnlisted,
                             NullLogger.Instance, CancellationToken.None).Result
                         .Select(metadata => new PackageSourceSearchMetadata(source, metadata));
                 })
                 .Distinct(new MetadataEqualityComparer())
                 .OrderByDescending(metadata => GetNuGetVersion(metadata).Version)
                 .ToArray();
             if (!AllVersions && Versions==null){
                 return metadatas.Take(1).ToArray();
             }

             if (Versions != null){
                 return metadatas.Where(metadata => {
                     var nuGetVersion = GetNuGetVersion(metadata).ToString();
                     return Versions.Contains(nuGetVersion);
                 }).ToArray();
             }

             return metadatas;
         }

         private static NuGetVersion GetNuGetVersion(IPackageSourceSearchMetadata metadata){
             if (metadata.Metadata is PackageSearchMetadata searchMetadata)
                 return searchMetadata.Version;
             if (metadata.Metadata is LocalPackageSearchMetadata  localPackageSearchMetadata)
                 return localPackageSearchMetadata.Identity.Version;
             return ((PackageSearchMetadataV2Feed) metadata.Metadata).Version;
         }
     }

 }
