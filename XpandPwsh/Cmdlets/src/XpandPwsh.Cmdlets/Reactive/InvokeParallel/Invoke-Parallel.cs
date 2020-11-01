using System;
using System.Collections.Concurrent;
using System.Collections.ObjectModel;
using System.Linq;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading;
using System.Threading.Tasks;
using JetBrains.Annotations;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.Reactive.InvokeParallel
{
    [Cmdlet(VerbsLifecycle.Invoke, "Parallel")]
    [CmdletBinding]
    [CmdLetTag(CmdLetTag.Reactive,CmdLetTag.RX)][PublicAPI]
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
        public int RetryOnError{ get; set; }

        [Parameter]
        public int LimitConcurrency{ get; set; } 

        [Parameter]
        public int RetryDelay{ get; set; } = 3000;

        [Parameter]
        public int StepInterval{ get; set; } = -1;
        [Parameter]
        public int First{ get; set; } = -1;

        [Parameter] public int Timeout { get; set; } = 2^32-3;

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
                values = values.StepInterval(TimeSpan.FromMilliseconds(StepInterval));
            }

            var retrySignal = Enumerable.Range(0, RetryOnError).ToObservable()
                .Delay(TimeSpan.FromMilliseconds(RetryDelay)).Publish().AutoConnect();
            values = LimitConcurrency > 0 ? InvokeWithLimit(values, retrySignal) : values.SelectMany(o => Start(o, retrySignal));
            if (First > -1){
                values = values.Take(First);
            }
            
            return values
                .WriteObject(this, _values.Count)
                .HandleErrors(this, ActivityName,SynchronizationContext.Current)
                .ToTask();
        }

        private IObservable<Collection<PSObject>> InvokeWithLimit(IObservable<object> values,IObservable<int> retrySignal) 
            => values.Select((o, i) => Start(o,retrySignal)).Merge(LimitConcurrency);

        private IObservable<Collection<PSObject>> Start(object o, IObservable<int> retrySignal) 
            => Observable.Defer(() => Observable.Start(() => {
                        using var runSpace = RunspaceFactory.CreateRunspace();
                        runSpace.Open();
                        runSpace.SetVariable(new PSVariable("_", o));
                        runSpace.SetVariable(_psVariables);
                        var psObjects = runSpace.Invoke($"[CmdletBinding()]\r\nParam()\r\n{Script}").Cast<PSObject>();
                        var lastExitCode = runSpace.Invoke("$LastExitCode").Any(_ => _?.BaseObject is int code&& code>0);
                        var errors = runSpace.Invoke("$Error").Where(_ => _?.BaseObject is ErrorRecord)
                            .GroupBy(exception => ((ErrorRecord) exception.BaseObject).Exception.Message)
                            .SelectMany(objects => objects);
                        var collection = new Collection<PSObject>();
                        foreach (var psObject in psObjects.Concat(errors)){
                            if (lastExitCode){
                                var targetObject = PSSerializer.Serialize(psObject, 3);
                                collection.Add(PSObject.AsPSObject(new ErrorRecord(new Exception(psObject.ToString()), ErrorCategory.FromStdErr.ToString(),
                                    ErrorCategory.FromStdErr, targetObject)));
                            }
                            else{
                                collection.Add(psObject);
                            }
                        }
                        return Observable.Return(collection);
                    }).Merge()
                    .RetryWhen(_ => _.SelectMany(exception => {
                        return retrySignal
                            .Select(i => i)
                            .Concat(Observable.Throw<int>(exception));
                    }))
                )
                .Timeout(TimeSpan.FromSeconds(Timeout));
    }
}