using System;
using System.Collections.Concurrent;
using System.Collections.ObjectModel;
using System.Linq;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Reactive.Concurrency;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading;
using System.Threading.Tasks;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.InvokeParallel{
    [Cmdlet(VerbsLifecycle.Invoke, "Parallel")]
    [CmdletBinding]
    public class InvokeParallel : XpandCmdlet{
        private PSVariable[] _psVariables;
        private ConcurrentBag<object> _values;

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
        public int LimitConcurrency{ get; set; } 

        [Parameter]
        public int RetryDelay{ get; set; } = 3000;

        [Parameter]
        public int StepInterval{ get; set; } = -1;

        protected override Task BeginProcessingAsync(){
            _values = new ConcurrentBag<object>();
            _psVariables = this.Invoke<PSVariable>("Get-Variable")
                .Where(variable => VariablesToImport.Select(s => s.ToLower()).Contains(variable.Name.ToLower())).ToArray();

            return base.BeginProcessingAsync();
        }

        protected override Task ProcessRecordAsync(){
            _values.Add(Value);
            return base.ProcessRecordAsync();
        }

        protected override Task EndProcessingAsync(){
            if (!_values.Any()) return Task.CompletedTask;
            if (_values.Count > Environment.ProcessorCount&&StepInterval==-1){
                StepInterval = 50;
            }
            var values = _values.ToObservable();
            if (StepInterval > 0){
                var eventLoopScheduler = new EventLoopScheduler(start => new Thread(start));
                values = values.StepInterval(TimeSpan.FromMilliseconds(StepInterval), eventLoopScheduler);
            }
            

            var retrySignal = Enumerable.Range(0, RetryOnError).ToObservable()
                .Delay(TimeSpan.FromMilliseconds(RetryDelay)).Publish().AutoConnect();
            values = LimitConcurrency > 0 ? InvokeWithLimit(values, retrySignal) : values.SelectMany(o => Start(o, retrySignal));
            return values
                .WriteObject(this, _values.Count)
                .HandleErrors(this, ActivityName,SynchronizationContext.Current)
                .ToTask();
        }

        private IObservable<Collection<PSObject>> InvokeWithLimit(IObservable<object> values,IObservable<int> retrySignal){
            return values.Select((o, i) => Observable.Defer(() => Start(o,retrySignal)))
                .Merge(LimitConcurrency);
        }

        private IObservable<Collection<PSObject>> Start(object o, IObservable<int> retrySignal){

            return Observable.Start(() => {
                using (var runspace = RunspaceFactory.CreateRunspace()){
                    runspace.Open();
                    runspace.SetVariable(new PSVariable("_", o));
                    runspace.SetVariable(_psVariables);
                    var psObjects = runspace.Invoke(Script.ToString());
                    var lastExitCode = runspace.Invoke("$LastExitCode").FirstOrDefault();
                    if (lastExitCode != null && (int) lastExitCode.BaseObject > 0){
                        var error = string.Join(Environment.NewLine, runspace.Invoke("$Error"));
                        runspace.Close();
                        if (!string.IsNullOrWhiteSpace(error))
                            throw new Exception(
                                $"ExitCode:{lastExitCode}{Environment.NewLine}Errors: {error}{Environment.NewLine}Script:{Script}");
                    }

                    runspace.Close();
                    return psObjects;
                }
            }).RetryWhen(_ => _.SelectMany(exception => retrySignal.Concat(Observable.Throw<int>(exception))));
        }
    }
}