using System.Management.Automation;
using System.Threading.Tasks;
using XpandPosh.Cmdlets;

namespace XpandPosh.CmdLets{
    public abstract class XpandCmdlet:AsyncCmdlet,IProgressCmdlet{
        protected XpandCmdlet(){
            ActivityName = CmdletExtensions.GetCmdletName(GetType());
        }

        protected override Task BeginProcessingAsync(){
            GetCallerPreference();    
            return base.BeginProcessingAsync();
        }

        protected virtual void GetCallerPreference(){
            CmdletExtensions.GetCallerPreference(this);
        }

        [Parameter]
        public int ActivityId{ get; set; }

        [Parameter]
        public string ActivityName{ get; set; }

        [Parameter]
        public string ActivityStatus{ get; set; } = "Done {0}%";

        [Parameter]
        public string CompletionMessage{ get; set; } = "Finished";

        void IProgressCmdlet.WriteProgressCompletion(ProgressRecord progressRecord, string completionMessage){
            WriteProgressCompletion(progressRecord, completionMessage);
        }
    }
}