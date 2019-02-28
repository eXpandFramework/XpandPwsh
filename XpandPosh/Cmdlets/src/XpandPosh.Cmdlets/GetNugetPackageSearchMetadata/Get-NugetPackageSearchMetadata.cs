using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
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
     public class GetNugetPackageSearchMetadata : PSCmdlet{
         [Parameter(Mandatory = true, ValueFromPipeline = true)]
         public string Name{ get; set; }

         [Parameter]
         public string[] Sources{ get; set; } = {"https://api.nuget.org/v3/index.json"};
         [Parameter]
         public SwitchParameter IncludePrerelease{ get; set; } =new SwitchParameter(false);
         [Parameter]
         public SwitchParameter IncludeUnlisted{ get; set; } = new SwitchParameter(false);
         [Parameter]
         public SwitchParameter AllVersions{ get; set; } = new SwitchParameter(false);

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
             try{
                 var metadatas = Sources.SelectMany(source => {
                     var providers = new List<Lazy<INuGetResourceProvider>>();
                     providers.AddRange(Repository.Provider.GetCoreV3()); 
                     var packageSource = new PackageSource(source);
                     var sourceRepository = new SourceRepository(packageSource, providers);
                     var packageMetadataResource = sourceRepository.GetResourceAsync<PackageMetadataResource>().Result;
                     return packageMetadataResource.GetMetadataAsync(Name, IncludePrerelease, IncludeUnlisted, NullLogger.Instance, CancellationToken.None).Result
                         .Select(metadata => new PackageSourceSearchMetadata(source, metadata));
                 })
                .Distinct(new MetadataEqualityComparer())
                .OrderByDescending(metadata => GetNuGetVersion(metadata).Version)
                .ToArray();
                 if (!AllVersions){
                     metadatas = metadatas.Take(1).ToArray();
                 }
                 WriteObject(metadatas, true);
             }
             catch (AggregateException e){
                 var flatten = e.Flatten();
                 WriteError(new ErrorRecord(flatten, flatten.GetType().FullName, ErrorCategory.InvalidOperation, Name));
                 flatten.Handle(_ => {
                     if (!(_ is AggregateException)){
                         WriteError(new ErrorRecord(_, _.GetType().FullName, ErrorCategory.InvalidOperation, Name));
                         return true;
                     }

                     return false;
                 });
                 throw;
             }
             catch (Exception e){
                 WriteError(new ErrorRecord(e, e.GetType().FullName, ErrorCategory.InvalidOperation, Name));
                 throw;
             }
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
