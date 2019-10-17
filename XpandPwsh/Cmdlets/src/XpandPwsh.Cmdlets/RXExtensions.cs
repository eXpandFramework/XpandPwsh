using System;
using System.Management.Automation;
using System.Reactive.Concurrency;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading;
using NuGet.Common;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets{
    internal static class RXExtensions{
        public static IObservable<T> StepInterval<T>(this IObservable<T> source, TimeSpan minDelay,IScheduler scheduler=null){
            scheduler = scheduler ?? Scheduler.CurrentThread;
            return source.Select(x => Observable.Empty<T>(scheduler)
                .Delay(minDelay,scheduler)
                .StartWith(scheduler,x)
            ).Concat();
        }

        public static IObservable<T> IgnoreException<T,TException>(this IObservable<T> source, PSCmdlet cmdlet,object targetObject) where  TException:Exception{
            return source.ObserveOn(SynchronizationContext.Current)
                .Catch<T, TException>(exception => {
                    cmdlet.WriteError(new ErrorRecord(exception, $"{exception.GetHashCode()}",ErrorCategory.InvalidOperation, targetObject));
                    return Observable.Empty<T>();
                });
        }

        public static IObservable<TSource> HandleErrors<TSource>(this IObservable<TSource> source,XpandCmdlet cmdlet, object targetObject=null,SynchronizationContext context=null){
            context = context ?? SynchronizationContext.Current;
            return source.HandleErrors<TSource, Exception>(cmdlet, targetObject,context);
        }

        public static IObservable<TSource> HandleErrors<TSource,TException>(this IObservable<TSource> source, XpandCmdlet cmdlet,object targetObject,SynchronizationContext context=null) where TException:Exception{
            context = context ?? SynchronizationContext.Current;
            targetObject = targetObject ?? cmdlet.ActivityName;
            return source.ObserveOn(context)
                .Catch<TSource,TException>(exception => {
                    var errorAction = cmdlet.ErrorAction();
                    if (errorAction==ActionPreference.SilentlyContinue)
                        return Observable.Return(default(TSource));
                    var errorRecord = new ErrorRecord(exception, exception.GetHashCode().ToString(),ErrorCategory.InvalidOperation, targetObject);
                    cmdlet.WriteError(errorRecord);
                    if (errorAction==ActionPreference.Stop){
                        return Observable.Throw<TSource>(exception);
                    }
                    if (errorAction==ActionPreference.Ignore||errorAction==ActionPreference.Continue)
                        return Observable.Empty<TSource>();
                    throw new NotImplementedException($"{errorAction}");
                });
        }

        public static IObservable<T> WriteProgress<T>(this IObservable<T> source, IProgressCmdlet cmdlet,int itemsCount){
            return source.Select((objects, i) => {
                var percentComplete = i * 100 / itemsCount;
                cmdlet.WriteProgress(new ProgressRecord(cmdlet.ActivityId, cmdlet.ActivityName,string.Format(cmdlet.ActivityStatus, percentComplete)){PercentComplete = percentComplete});
                return objects;
            }).Finally(() => cmdlet.WriteProgressCompletion(new ProgressRecord(cmdlet.ActivityId, cmdlet.ActivityName, cmdlet.ActivityStatus){PercentComplete = 100},cmdlet.CompletionMessage));
        }

        public static IObservable<T> WriteVerboseObject<T>(this IObservable<T> source, Cmdlet cmdlet,Func<T,string> text=null,SynchronizationContext synchronizationContext=null){
            synchronizationContext = synchronizationContext ?? SynchronizationContext.Current;
            text = text ?? (arg => $"{arg.GetType().Name}{arg}");
            return source.ObserveOn(synchronizationContext).Select((arg1, i) => {
                if (arg1 != null){
                    cmdlet.WriteVerbose($"{text(arg1)}");
                }
                return arg1;
            });
        }

        public static IObservable<T> WriteObject<T>(this IObservable<T> source,Cmdlet cmdlet,int? progressItemsTotalCount=null,bool enumerateCollection=true,Func<T,object> output=null){
            var writeObject = source
                .ObserveOn(SynchronizationContext.Current)
                .Select(obj => {
                var o = output?.Invoke(obj)??obj;
                cmdlet.WriteObject(o, enumerateCollection);
                return obj;
            });
            return progressItemsTotalCount.HasValue ? writeObject.WriteProgress((IProgressCmdlet) cmdlet, progressItemsTotalCount.Value) : writeObject;
        }

        public static IObservable<T> ToObservable<T>(this IEnumeratorAsync<T> enumeratorAsync){
            var nextItem = Observable.Defer(() => enumeratorAsync.MoveNextAsync().ToObservable());
            return nextItem.Repeat().TakeUntil(b => !b).Select(b => enumeratorAsync.Current);
        }
    }
}