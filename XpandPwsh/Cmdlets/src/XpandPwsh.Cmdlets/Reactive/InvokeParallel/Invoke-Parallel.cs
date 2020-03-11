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

namespace XpandPwsh.Cmdlets.Reactive.InvokeParallel{
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

        private IObservable<Collection<PSObject>> InvokeWithLimit(IObservable<object> values,IObservable<int> retrySignal){
            return values.Select((o, i) => Start(o,retrySignal))
                .Merge(LimitConcurrency);
        }

        private IObservable<Collection<PSObject>> Start(object o, IObservable<int> retrySignal){
            return Observable.Defer(() => Observable.Start(() => {
                        using (var runspace = RunspaceFactory.CreateRunspace()){
                            runspace.Open();
                            runspace.SetVariable(new PSVariable("_", o));
                            runspace.SetVariable(_psVariables);
                            var psObjects = runspace.Invoke($"[CmdletBinding()]\r\nParam()\r\n{Script}");

                            var errors = runspace.Invoke("$Error").Where(_ => _ != null)
                                .Select(psObject => psObject.BaseObject).OfType<ErrorRecord>().Select(record => record.Exception).ToObservable()
                                .GroupBy(exception => exception.Message).SelectMany(_ => _.FirstAsync())
                                .SelectMany(Observable.Throw<Collection<PSObject>>);
                            var invalidExitCode = runspace.Invoke("$LastExitCode")
                                .Where(_ => _ != null && (int) _.BaseObject > 0).ToObservable()
                                .SelectMany(_ => Observable.Throw<Collection<PSObject>>(new Exception($"LastExitCode: {_.BaseObject}")));

                            return invalidExitCode.Concat(errors).Concat(Observable.Return(psObjects));
                        }
                    }).Merge()
                    .RetryWhen(_ => _.SelectMany(exception => {
                        return retrySignal
                            .Select(i => i)
                            .Concat(Observable.Throw<int>(exception));
                    }))
                )
                ;
        }
    }
}