using System;
using System.Linq;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading;
using NuGet.Common;
using XpandPosh.CmdLets;

namespace XpandPosh.Cmdlets{
    internal static class RXExtensions{
        public static IObservable<TSource> Catch<TSource>(this IObservable<TSource> source,PSCmdlet cmdlet, object targetObject){
            return source.Catch<TSource, Exception>(cmdlet, targetObject);
        }

        public static IObservable<TSource> Catch<TSource,TException>(this IObservable<TSource> source, PSCmdlet cmdlet,object targetObject) where TException:Exception{
            var synchronizationContext = SynchronizationContext.Current;
            var errorAction = cmdlet.ErrorAction();
            return source.ObserveOn(synchronizationContext)
                .Catch<TSource,TException>(exception => {
                    if (errorAction==ActionPreference.Stop)
                        return Observable.Empty<TSource>();
                    if (!new[]{ActionPreference.Ignore, ActionPreference.SilentlyContinue}.Contains(errorAction)){
                        var errorRecord = new ErrorRecord(exception, exception.GetHashCode().ToString(),ErrorCategory.InvalidOperation, targetObject);
                        cmdlet.WriteError(errorRecord);
                    }
                    return Observable.Empty<TSource>();
                });
        }

        public static IObservable<T> WriteObject<T>(this IObservable<T> source,Cmdlet cmdlet){
            var synchronizationContext = SynchronizationContext.Current;
            return source.ObserveOn(synchronizationContext).Do(obj => cmdlet.WriteObject(obj));
        }

        public static IObservable<T> ToObservable<T>(this IEnumeratorAsync<T> enumeratorAsync){
            var nextItem = Observable.Defer(() => enumeratorAsync.MoveNextAsync().ToObservable());
            return nextItem.Repeat().TakeUntil(b => !b).Select(b => enumeratorAsync.Current);
        }
    }
}