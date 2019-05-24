using System;
using System.Collections.Concurrent;
using System.Linq;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Reactive.Concurrency;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading;
using System.Threading.Tasks;
using XpandPosh.CmdLets;

namespace XpandPosh.Cmdlets.InvokeParallel{
    [Cmdlet(VerbsLifecycle.Invoke, "Parallel")]
    [CmdletBinding]
    public class InvokeParallel : XpandCmdlet{
        private ConcurrentBag<object> _values;
        private PSVariable[] _psVariables;

        [Parameter]
        public override string ActivityName{ get; set; }

        [Parameter(Mandatory = true, Position = 1)]
        public ScriptBlock Script{ get; set; }

        [Parameter]
        public string[] VariablesToImport{ get; set; } = new string[0];

        [Parameter(Mandatory = true, Position = 0, ValueFromPipeline = true)]
        public object Value{ get; set; }
        [Parameter]
        public override int ActivityId{ get; set; }

        [Parameter]
        public int RetryOnError{ get; set; } = 0;

        [Parameter]
        public int RetryDelay{ get; set; } = 3000;
        [Parameter]
        public int StepInterval{ get; set; } 
        protected override Task BeginProcessingAsync(){
            _values = new ConcurrentBag<object>();
            _psVariables = this.Invoke<PSVariable>("Get-Variable")
                .Where(variable => VariablesToImport.Contains(variable.Name)).ToArray();
            return base.BeginProcessingAsync();
        }

        protected override Task ProcessRecordAsync(){
            _values.Add(Value);
            return base.ProcessRecordAsync();
        }

        protected override Task EndProcessingAsync(){
            if (!_values.Any()){
                return Task.CompletedTask;
            }
            var signal = Enumerable.Range(0,RetryOnError).ToObservable()
                .Delay(TimeSpan.FromMilliseconds(RetryDelay)).Publish().AutoConnect();
            var eventLoopScheduler = new EventLoopScheduler(start => new Thread(start));
            var synchronizationContext = SynchronizationContext.Current;
            var values = _values.ToObservable();
            if (StepInterval > 0){
                values=values.StepInterval(TimeSpan.FromMilliseconds(StepInterval),eventLoopScheduler);
            }
            return values
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
                    .RetryWhen(_ => _.SelectMany(exception => signal.Concat(Observable.Throw<int>(exception))))
                    .HandleErrors(this, ActivityName,synchronizationContext))
                .WriteObject(this,_values.Count)
                .ToTask();
        }

        
    }
}