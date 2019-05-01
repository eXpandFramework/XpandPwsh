using System.Collections.Concurrent;
using System.Management.Automation;
using System.Net;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading;
using System.Threading.Tasks;
using Newtonsoft.Json;
using NuGet.Protocol.Core.Types;
using XpandPosh.CmdLets;

namespace XpandPosh.Cmdlets.Nuget{
    [Cmdlet(VerbsCommon.Get, "NugetPackageDownloadsCount")]
    [CmdletBinding]
    public class GetNugetPackageDownloadsCount : XpandCmdlet{
        private ConcurrentBag<string> _packages;

        [Parameter(ValueFromPipeline = true, Mandatory = true)]
        public string Id{ get; set; }

        [Parameter(Mandatory = true)]
        public string Source{ get; set; }

        protected override Task BeginProcessingAsync(){
            _packages = new ConcurrentBag<string>();
            return base.BeginProcessingAsync();
        }

        protected override Task ProcessRecordAsync(){
            _packages.Add(Id);
            return Task.CompletedTask;
        }

        protected override async Task EndProcessingAsync(CancellationToken cancellationToken){
            var sum = await _packages.ToObservable()
                .SelectMany(id => Observable.Using(() => new WebClient(), client => client
                    .DownloadStringTaskAsync(
                        $"https://api-v2v3search-0.nuget.org/query?q=packageid:{id}").ToObservable()))
                .Sum(json => (int) JsonConvert.DeserializeObject<dynamic>(json).data[0].totalDownloads);
            WriteObject(sum);
        }
    }
}