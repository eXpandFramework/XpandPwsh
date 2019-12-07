using System;
using System.ComponentModel.DataAnnotations;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;

namespace XpandPwsh.Cmdlets.Nuget{
    [Cmdlet(VerbsCommon.Get, "XAFLatestMinors")]
    [CmdletBinding]
    public class GetXAFLatestMinors : NugetCmdlet{
        [Parameter]
        public string Source{ get; set; } = Environment.GetEnvironmentVariable("DXFeed");

        [Parameter]
        public int? Top{ get; set; } = 3;

        protected override Task BeginProcessingAsync(){
            
            if (Source == null){
                throw new ValidationException("Parameter Source cannot be empty");
            }
            return base.BeginProcessingAsync();
        }

        protected override  Task ProcessRecordAsync(){
            return Providers.GetLatestMinors(Source, "DevExpress.ExpressApp", Top).ToObservable().ToTask().WriteObject(this);
        }



    }
}

