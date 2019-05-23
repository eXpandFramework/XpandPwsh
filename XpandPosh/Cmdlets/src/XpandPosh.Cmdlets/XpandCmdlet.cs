using System;
using System.Management.Automation;
using System.Threading.Tasks;

namespace XpandPosh.CmdLets{
    public abstract class XpandCmdlet:AsyncCmdlet{
        public  string ActivityStatus= "Done {0}%";
        public  int ActivityId;
        public  string CompletionMessage= "Finished";
        protected XpandCmdlet(){
            ActivityId = (int) Math.Abs(DateTime.Now.Ticks);
        }

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

        public virtual string ActivityName{ get; set; }

        public new void WriteProgressCompletion(ProgressRecord progressRecord, string completionMessageOrFormat, params object[] formatArguments){
        }

    }
}