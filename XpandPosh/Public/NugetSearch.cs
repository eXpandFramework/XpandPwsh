using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Threading;
using System.Threading.Tasks;
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
        public string Name{ get; set; } = string.Empty;
        [Parameter]
        public SwitchParameter AllVersions{ get; set; } 
        [Parameter]
        public SwitchParameter IncludePrerelease{ get; set; } =SwitchParameter.Present;
        [Parameter]
        public SwitchParameter IncludeUnlisted{ get; set; } = SwitchParameter.Present;

        protected override void ProcessRecord(){
            base.ProcessRecord();
            try{
                var packageSearchMetadata = Find(Name, IncludeUnlisted, IncludePrerelease).Result;
                if (!AllVersions)
                    packageSearchMetadata = new[]{packageSearchMetadata.Last()};

                WriteObject(packageSearchMetadata, true);
            }
            catch (AggregateException e){
                var flatten = e.Flatten();
                flatten.Flatten().Handle(_ => {
                    if (_ is AggregateException){
                        WriteError(new ErrorRecord(flatten, _.GetType().FullName, ErrorCategory.InvalidOperation, Name));
                        return true;
                    }

                    return false;
                });
            }
        }

        async Task<IEnumerable<IPackageSearchMetadata>> Find(string packageID,bool includeUnlisted, bool includePrerelease){
            var providers = new List<Lazy<INuGetResourceProvider>>();
            providers.AddRange(Repository.Provider.GetCoreV3());
            var packageSource = new PackageSource("https://api.nuget.org/v3/index.json");
            var sourceRepository = new SourceRepository(packageSource, providers);
            var packageMetadataResource = await sourceRepository.GetResourceAsync<PackageMetadataResource>();
            return await packageMetadataResource.GetMetadataAsync(packageID, includePrerelease, includeUnlisted, new NullLogger(), CancellationToken.None);
        }
    }
}
        
