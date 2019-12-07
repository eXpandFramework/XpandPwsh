using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Net;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.Nuget{
    [Cmdlet(VerbsCommon.Get, "NugetPackageDownloadsCount")]
    [CmdletBinding]
    public class GetNugetPackageDownloadsCount : XpandCmdlet{
        private ConcurrentBag<string> _packages;

        [Parameter(ValueFromPipeline = true, Mandatory = true)]
        public string Id{ get; set; }

        
        [Parameter]
        public SwitchParameter Latest{ get; set; }
        [Parameter]
        public Version Version{ get; set; }
        protected override Task BeginProcessingAsync(){
            _packages = new ConcurrentBag<string>();
            return base.BeginProcessingAsync();
        }

        protected override Task ProcessRecordAsync(){
            _packages.Add(Id);
            return Task.CompletedTask;
        }

        protected override async Task EndProcessingAsync(CancellationToken cancellationToken){
            var concurrentBag = _packages;
            var downloads = Downloads(concurrentBag,Latest,Version);
            var sum = await downloads;
            WriteObject(sum);
        }

        public static IObservable<int> Downloads(IEnumerable<string> packages,bool latest=false,Version version=null){
            var query = packages.ToObservable()
                .SelectMany(id => Observable.Using(() => new WebClient(), client => client
                    .DownloadStringTaskAsync(
                        $"https://api-v2v3search-0.nuget.org/query?q=packageid:{id}").ToObservable()));
            
            var downloads = query
                .Sum(json => {
                    var data = JsonConvert.DeserializeObject<dynamic>(json).data;
                    if (data.Count == 0)
                        return 0;
                    data = data[0]; 
                    if (latest){
                        return data.versions.Last.downloads;
                    }
                    if (version != null){
                        return ((dynamic) ((JArray) data.versions).Children<JObject>().First(o => o["version"].ToString() ==version.ToString())).downloads;
                    }
                    return (int) data.totalDownloads;
                });
            return downloads;
        }
    }
}