using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using XpandPosh.CmdLets;

namespace XpandPosh.Cmdlets{
    [Cmdlet(VerbsLifecycle.Invoke, "Parallel")]
    [CmdletBinding]
    public class InvokeParallel : XpandCmdlet{
        private List<object> _values;
        private PSVariable[] _psVariables;

        
        [Parameter(Mandatory = true, Position = 3)]
        public ScriptBlock Script{ get; set; }

        [Parameter]
        public string[] VariablesToImport{ get; set; } = new string[0];

        [Parameter(Mandatory = true, Position = 2, ValueFromPipeline = true)]
        public object Value{ get; set; }

        protected override Task BeginProcessingAsync(){
            _values = new List<object>();
            _psVariables = this.Invoke<PSVariable>("Get-Variable")
                .Where(variable => VariablesToImport.Contains(variable.Name)).ToArray();
            return base.BeginProcessingAsync();
        }

        protected override Task ProcessRecordAsync(){
            _values.Add(Value);
            return base.ProcessRecordAsync();
        }

        protected override Task EndProcessingAsync(){
            return _values.ToObservable()
                .SelectMany((o, i) => Observable.Start(() => {
                        using (var runspace = RunspaceFactory.CreateRunspace()){
                            runspace.Open();
                            runspace.SetVariable(new PSVariable("_", o));
                            runspace.SetVariable(_psVariables);
                            var psObjects = runspace.Invoke(Script.ToString());
                            var lastExitCode = runspace.Invoke("$LastExitCode").FirstOrDefault();
                            if (lastExitCode != null&& ((int) lastExitCode.BaseObject) >0){
                                var error = string.Join(Environment.NewLine,runspace.Invoke("$Error"));
                                if (!string.IsNullOrWhiteSpace(error)){
                                    throw new Exception($"ExitCode:{lastExitCode}{Environment.NewLine}Errors: {error}{Environment.NewLine}Script:{Script}");
                                }
                            }
                            runspace.Close();
                            return psObjects;
                        }
                    })
                    .HandleErrors(this, ActivityName))
                .WriteObject(this,_values.Count)
                .ToTask();
        }
    }
}