using System.Management.Automation;

namespace XpandPwsh.Cmdlets{
    public interface IProgressCmdlet{
        int ActivityId{ get; }
        string ActivityName{ get; }
        string ActivityStatus{ get; }
        string CompletionMessage{ get; set; }
        void WriteProgress(ProgressRecord progressRecord);
        void WriteProgressCompletion(ProgressRecord progressRecord, string completionMessage);
    }
}