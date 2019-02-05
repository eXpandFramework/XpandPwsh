 using System;
 using System.Collections.Generic;
 using System.Linq;
 using System.Management.Automation;
 using System.Threading;
 using NuGet.Common;
 using NuGet.Configuration;
 using NuGet.Protocol;
 using NuGet.Protocol.Core.Types;
 namespace NugetSearch{
     [Cmdlet(VerbsCommon.Get, "NugetPackageSearchMetadata")]
     [OutputType(typeof(IPackageSearchMetadata))]
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

         class MetadataEqualityComparer:IEqualityComparer<PackageSearchMetadata>{
             public bool Equals(PackageSearchMetadata x, PackageSearchMetadata y){
                 return x?.Identity.Id == y?.Identity.Id && x?.Version == y?.Version;
             }

             public int GetHashCode(PackageSearchMetadata obj){
                 return $"{obj.Identity.Id}{obj.Version.Version}".GetHashCode();
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
                     return packageMetadataResource.GetMetadataAsync(Name, IncludePrerelease, IncludeUnlisted, NullLogger.Instance, CancellationToken.None).Result;
                 })
                .Cast<PackageSearchMetadata>()
                .Distinct(new MetadataEqualityComparer())
                .OrderByDescending(metadata => metadata.Version.Version)
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

     }

 }
