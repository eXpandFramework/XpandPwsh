using System.Management.Automation;
using System.Threading.Tasks;
using XpandPwsh.Cmdlets;

namespace XpandPwsh.CmdLets{
    public abstract class XpandCmdlet:AsyncCmdlet,IProgressCmdlet{
        protected override Task BeginProcessingAsync(){
            if (ActivityName == null){
                ActivityName = CmdletExtensions.GetCmdletName(GetType());
            }
            GetCallerPreference();    
            return base.BeginProcessingAsync();
        }

        protected virtual void GetCallerPreference(){
            CmdletExtensions.GetCallerPreference(this);
        }

        
        
        public virtual int ActivityId{ get; set; }

        
        public virtual string ActivityName{ get; set; }

        
        public string ActivityStatus{ get; set; } = "Done {0}%";

        
        public string CompletionMessage{ get; set; } = "Finished";

        void IProgressCmdlet.WriteProgressCompletion(ProgressRecord progressRecord, string completionMessage){
            WriteProgressCompletion(progressRecord, completionMessage);
        }
    }
}