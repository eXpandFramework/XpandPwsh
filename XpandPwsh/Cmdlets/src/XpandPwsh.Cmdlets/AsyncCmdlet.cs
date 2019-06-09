using System;
using System.Collections.Concurrent;
using System.Management.Automation;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Runtime.ExceptionServices;

namespace XpandPwsh.CmdLets{

    /// <summary>
    ///     Base class for Cmdlets that run asynchronously.
    /// </summary>
    /// <remarks>
    ///     Inherit from this class if your Cmdlet needs to use <c>async</c> / <c>await</c> functionality.
    /// </remarks>
    public abstract class AsyncCmdlet
        : PSCmdlet, IDisposable{
        /// <summary>
        ///     The source for cancellation tokens that can be used to cancel the operation.
        /// </summary>
        private readonly CancellationTokenSource _cancellationSource = new CancellationTokenSource();

        /// <summary>
        ///     Dispose of resources being used by the Cmdlet.
        /// </summary>
        public void Dispose(){
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        /// <summary>
        ///     Finaliser for <see cref="AsyncCmdlet" />.
        /// </summary>
        ~AsyncCmdlet(){
            Dispose(false);
        }

        /// <summary>
        ///     Dispose of resources being used by the Cmdlet.
        /// </summary>
        /// <param name="disposing">
        ///     Explicit disposal?
        /// </param>
        protected virtual void Dispose(bool disposing){
            if (disposing)
                _cancellationSource.Dispose();
        }

        /// <summary>
        ///     Asynchronously perform Cmdlet pre-processing.
        /// </summary>
        /// <returns>
        ///     A <see cref="Task" /> representing the asynchronous operation.
        /// </returns>
        protected virtual Task BeginProcessingAsync(){
            return BeginProcessingAsync(_cancellationSource.Token);
        }

        /// <summary>
        ///     Asynchronously perform Cmdlet pre-processing.
        /// </summary>
        /// <param name="cancellationToken">
        ///     A <see cref="CancellationToken" /> that can be used to cancel the asynchronous operation.
        /// </param>
        /// <returns>
        ///     A <see cref="Task" /> representing the asynchronous operation.
        /// </returns>
        protected virtual Task BeginProcessingAsync(CancellationToken cancellationToken){
            return Task.CompletedTask;
        }

        /// <summary>
        ///     Asynchronously perform Cmdlet processing.
        /// </summary>
        /// <returns>
        ///     A <see cref="Task" /> representing the asynchronous operation.
        /// </returns>
        protected virtual Task ProcessRecordAsync(){
            return ProcessRecordAsync(_cancellationSource.Token);
        }

        /// <summary>
        ///     Asynchronously perform Cmdlet processing.
        /// </summary>
        /// <param name="cancellationToken">
        ///     A <see cref="CancellationToken" /> that can be used to cancel the asynchronous operation.
        /// </param>
        /// <returns>
        ///     A <see cref="Task" /> representing the asynchronous operation.
        /// </returns>
        protected virtual Task ProcessRecordAsync(CancellationToken cancellationToken){
            return Task.CompletedTask;
        }

        /// <summary>
        ///     Asynchronously perform Cmdlet post-processing.
        /// </summary>
        /// <returns>
        ///     A <see cref="Task" /> representing the asynchronous operation.
        /// </returns>
        protected virtual Task EndProcessingAsync(){
            return EndProcessingAsync(_cancellationSource.Token);
        }

        /// <summary>
        ///     Asynchronously perform Cmdlet post-processing.
        /// </summary>
        /// <param name="cancellationToken">
        ///     A <see cref="CancellationToken" /> that can be used to cancel the asynchronous operation.
        /// </param>
        /// <returns>
        ///     A <see cref="Task" /> representing the asynchronous operation.
        /// </returns>
        protected virtual Task EndProcessingAsync(CancellationToken cancellationToken){
            return Task.CompletedTask;
        }

        /// <summary>
        ///     Perform Cmdlet pre-processing.
        /// </summary>
        protected sealed override void BeginProcessing(){
            ThreadAffinitiveSynchronizationContext.RunSynchronized(BeginProcessingAsync);
        }

        /// <summary>
        ///     Perform Cmdlet processing.
        /// </summary>
        protected sealed override void ProcessRecord(){
            ThreadAffinitiveSynchronizationContext.RunSynchronized(ProcessRecordAsync);
        }

        /// <summary>
        ///     Perform Cmdlet post-processing.
        /// </summary>
        protected sealed override void EndProcessing(){
            ThreadAffinitiveSynchronizationContext.RunSynchronized(EndProcessingAsync);
        }

        /// <summary>
        ///     Interrupt Cmdlet processing (if possible).
        /// </summary>
        protected sealed override void StopProcessing(){
            _cancellationSource.Cancel();

            base.StopProcessing();
        }

        /// <summary>
        ///     Write a progress record to the output stream, and as a verbose message.
        /// </summary>
        /// <param name="progressRecord">
        ///     The progress record to write.
        /// </param>
        protected void WriteVerboseProgress(ProgressRecord progressRecord){
            if (progressRecord == null)
                throw new ArgumentNullException(nameof(progressRecord));

            WriteProgress(progressRecord);
            WriteVerbose(progressRecord.StatusDescription);
        }

        /// <summary>
        ///     Write a progress record to the output stream, and as a verbose message.
        /// </summary>
        /// <param name="progressRecord">
        ///     The progress record to write.
        /// </param>
        /// <param name="messageOrFormat">
        ///     The message or message-format specifier.
        /// </param>
        /// <param name="formatArguments">
        ///     Optional format arguments.
        /// </param>
        protected void WriteVerboseProgress(ProgressRecord progressRecord, string messageOrFormat,
            params object[] formatArguments){
            if (progressRecord == null)
                throw new ArgumentNullException(nameof(progressRecord));

            if (string.IsNullOrWhiteSpace(messageOrFormat))
                throw new ArgumentException(
                    "Argument cannot be null, empty, or composed entirely of whitespace: 'messageOrFormat'.",
                    nameof(messageOrFormat));

            if (formatArguments == null)
                throw new ArgumentNullException(nameof(formatArguments));

            progressRecord.StatusDescription = string.Format(messageOrFormat, formatArguments);
            WriteVerboseProgress(progressRecord);
        }

        /// <summary>
        ///     Write a completed progress record to the output stream.
        /// </summary>
        /// <param name="progressRecord">
        ///     The progress record to complete.
        /// </param>
        /// <param name="completionMessageOrFormat">
        ///     The completion message or message-format specifier.
        /// </param>
        /// <param name="formatArguments">
        ///     Optional format arguments.
        /// </param>
        protected void WriteProgressCompletion(ProgressRecord progressRecord, string completionMessageOrFormat,
            params object[] formatArguments){
            if (progressRecord == null)
                throw new ArgumentNullException(nameof(progressRecord));

            if (string.IsNullOrWhiteSpace(completionMessageOrFormat))
                throw new ArgumentException(
                    "Argument cannot be null, empty, or composed entirely of whitespace: 'completionMessageOrFormat'.",
                    nameof(completionMessageOrFormat));

            if (formatArguments == null)
                throw new ArgumentNullException(nameof(formatArguments));

            progressRecord.StatusDescription = string.Format(completionMessageOrFormat, formatArguments);
            progressRecord.PercentComplete = 100;
            progressRecord.RecordType = ProgressRecordType.Completed;
            WriteProgress(progressRecord);
            WriteVerbose(progressRecord.StatusDescription);
        }
    }

    /// <summary>
    ///     A synchronisation context that runs all calls scheduled on it (via <see cref="SynchronizationContext.Post" />) on a
    ///     single thread.
    /// </summary>
    /// <remarks>
    ///     With thanks to Stephen Toub.
    /// </remarks>
    public sealed class ThreadAffinitiveSynchronizationContext
        : SynchronizationContext, IDisposable{
        /// <summary>
        ///     A blocking collection (effectively a queue) of work items to execute, consisting of callback delegates and their
        ///     callback state (if any).
        /// </summary>
        private BlockingCollection<KeyValuePair<SendOrPostCallback, object>> _workItemQueue =
            new BlockingCollection<KeyValuePair<SendOrPostCallback, object>>();

        /// <summary>
        ///     Create a new thread-affinitive synchronisation context.
        /// </summary>
        private ThreadAffinitiveSynchronizationContext(){
        }

        /// <summary>
        ///     Dispose of resources being used by the synchronisation context.
        /// </summary>
        void IDisposable.Dispose(){
            if (_workItemQueue != null){
                _workItemQueue.Dispose();
                _workItemQueue = null;
            }
        }

        /// <summary>
        ///     Check if the synchronisation context has been disposed.
        /// </summary>
        private void CheckDisposed(){
            if (_workItemQueue == null)
                throw new ObjectDisposedException(GetType().Name);
        }

        /// <summary>
        ///     Run the message pump for the callback queue on the current thread.
        /// </summary>
        private void RunMessagePump(){
            CheckDisposed();

            while (_workItemQueue.TryTake(out var workItem, Timeout.InfiniteTimeSpan)){
                workItem.Key(workItem.Value);

                // Has the synchronisation context been disposed?
                if (_workItemQueue == null)
                    break;
            }
        }

        /// <summary>
        ///     Terminate the message pump once all callbacks have completed.
        /// </summary>
        private void TerminateMessagePump(){
            CheckDisposed();

            _workItemQueue.CompleteAdding();
        }

        /// <summary>
        ///     Dispatch an asynchronous message to the synchronization context.
        /// </summary>
        /// <param name="callback">
        ///     The <see cref="SendOrPostCallback" /> delegate to call in the synchronisation context.
        /// </param>
        /// <param name="callbackState">
        ///     Optional state data passed to the callback.
        /// </param>
        /// <exception cref="InvalidOperationException">
        ///     The message pump has already been started, and then terminated by calling <see cref="TerminateMessagePump" />.
        /// </exception>
        public override void Post(SendOrPostCallback callback, object callbackState){
            if (callback == null)
                throw new ArgumentNullException(nameof(callback));

            CheckDisposed();

            try{
                _workItemQueue.Add(
                    new KeyValuePair<SendOrPostCallback, object>(
                        callback,
                        callbackState
                    )
                );
            }
            catch (InvalidOperationException eMessagePumpAlreadyTerminated){
                throw new InvalidOperationException(
                    "Cannot enqueue the specified callback because the synchronisation context's message pump has already been terminated.",
                    eMessagePumpAlreadyTerminated
                );
            }
        }

        /// <summary>
        ///     Run an asynchronous operation using the current thread as its synchronisation context.
        /// </summary>
        /// <param name="asyncOperation">
        ///     A <see cref="Func{TResult}" /> delegate representing the asynchronous operation to run.
        /// </param>
        public static void RunSynchronized(Func<Task> asyncOperation){
            if (asyncOperation == null)
                throw new ArgumentNullException(nameof(asyncOperation));

            var savedContext = Current;
            try{
                using (var synchronizationContext = new ThreadAffinitiveSynchronizationContext()){
                    SetSynchronizationContext(synchronizationContext);

                    var rootOperationTask = asyncOperation();
                    if (rootOperationTask == null)
                        throw new InvalidOperationException("The asynchronous operation delegate cannot return null.");

                    rootOperationTask.ContinueWith(
                        operationTask =>
                            // ReSharper disable once AccessToDisposedClosure
                            synchronizationContext.TerminateMessagePump(),
                        TaskScheduler.Default
                    );

                    synchronizationContext.RunMessagePump();

                    try{
                        rootOperationTask
                            .GetAwaiter()
                            .GetResult();
                    }
                    catch (AggregateException eWaitForTask
                    ) // The TPL will almost always wrap an AggregateException around any exception thrown by the async operation.
                    {
                        // Is this just a wrapped exception?
                        var flattenedAggregate = eWaitForTask.Flatten();
                        if (flattenedAggregate.InnerExceptions.Count != 1)
                            throw; // Nope, genuine aggregate.

                        // Yep, so rethrow (preserving original stack-trace).
                        ExceptionDispatchInfo.Capture(flattenedAggregate.InnerExceptions[0]).Throw();
                    }
                }
            }
            finally{
                SetSynchronizationContext(savedContext);
            }
        }

        /// <summary>
        ///     Run an asynchronous operation using the current thread as its synchronisation context.
        /// </summary>
        /// <typeparam name="TResult">
        ///     The operation result type.
        /// </typeparam>
        /// <param name="asyncOperation">
        ///     A <see cref="Func{TResult}" /> delegate representing the asynchronous operation to run.
        /// </param>
        /// <returns>
        ///     The operation result.
        /// </returns>
        public static TResult RunSynchronized<TResult>(Func<Task<TResult>> asyncOperation){
            if (asyncOperation == null)
                throw new ArgumentNullException(nameof(asyncOperation));

            var savedContext = Current;
            try{
                using (var synchronizationContext = new ThreadAffinitiveSynchronizationContext()){
                    SetSynchronizationContext(synchronizationContext);

                    var rootOperationTask = asyncOperation();
                    if (rootOperationTask == null)
                        throw new InvalidOperationException("The asynchronous operation delegate cannot return null.");

                    rootOperationTask.ContinueWith(
                        operationTask =>
                            // ReSharper disable once AccessToDisposedClosure
                            synchronizationContext.TerminateMessagePump(),
                        TaskScheduler.Default
                    );

                    synchronizationContext.RunMessagePump();

                    try{
                        return
                            rootOperationTask
                                .GetAwaiter()
                                .GetResult();
                    }
                    catch (AggregateException eWaitForTask
                    ) // The TPL will almost always wrap an AggregateException around any exception thrown by the async operation.
                    {
                        // Is this just a wrapped exception?
                        var flattenedAggregate = eWaitForTask.Flatten();
                        if (flattenedAggregate.InnerExceptions.Count != 1)
                            throw; // Nope, genuine aggregate.

                        // Yep, so rethrow (preserving original stack-trace).
                        ExceptionDispatchInfo
                            .Capture(
                                flattenedAggregate
                                    .InnerExceptions[0]
                            )
                            .Throw();

                        throw; // Never reached.
                    }
                }
            }
            finally{
                SetSynchronizationContext(savedContext);
            }
        }
    }
}