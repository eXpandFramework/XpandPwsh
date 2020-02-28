using System;
using System.Collections.Generic;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using JetBrains.Annotations;
using MoreLinq;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.Reactive.GetFirstOrDefaultAsync{
    [Cmdlet(VerbsCommon.Get, "FirstOrDefaultAsync")]
    [CmdletBinding][CmdLetTag(CmdLetTag.RX,CmdLetTag.Reactive)][PublicAPI]
    public class GetFirstOrDefaultAsync : XpandCmdlet{
        private List<object> _values;

        [Parameter(Mandatory = true, Position = 0, ValueFromPipeline = true)]
        public object Value{ get; set; }
        [Parameter(Mandatory = true)]
        public Func<object,object> KeySelector{ get; set; }

        protected override Task BeginProcessingAsync(){
            _values = new List<object>();
            
            return base.BeginProcessingAsync();
        }

        protected override Task ProcessRecordAsync(){
            _values.Add(Value);
            return base.ProcessRecordAsync();
        }

        protected override Task EndProcessingAsync(){
            return Observable.Return(_values.DistinctBy(o =>KeySelector(o) )).ToTask();
        }

        
    }
}