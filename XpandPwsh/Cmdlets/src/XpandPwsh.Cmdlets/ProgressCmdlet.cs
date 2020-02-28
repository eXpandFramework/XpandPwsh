using System.Management.Automation;
using JetBrains.Annotations;

namespace XpandPwsh.Cmdlets{
    [PublicAPI]
    public interface IProgressCmdlet{
        int ActivityId{ get; }
        string ActivityName{ get; }
        string ActivityStatus{ get; }
        string CompletionMessage{ get; set; }
        void WriteProgress(ProgressRecord progressRecord);
        void WriteProgressCompletion(ProgressRecord progressRecord, string completionMessage);
    }
}