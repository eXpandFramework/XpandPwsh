using System;
using System.Management.Automation;
using System.Threading.Tasks;

namespace XpandPosh.CmdLets{
    public abstract class XpandCmdlet:AsyncCmdlet{
        public  string ActivityStatus= "Done {0}%";
        public  int ActivityId;
        public  string CompletionMessage= "Finished";
        protected XpandCmdlet(){
            ActivityName = CmdletExtensions.GetCmdletName(GetType());
            ActivityId = (int) DateTime.Now.Ticks;
        }

        protected override Task BeginProcessingAsync(){
            GetCallerPreference();    
            return base.BeginProcessingAsync();
        }

        protected virtual void GetCallerPreference(){
            CmdletExtensions.GetCallerPreference(this);
        }

        public string ActivityName{ get;  }

        public new void WriteProgressCompletion(ProgressRecord progressRecord, string completionMessageOrFormat, params object[] formatArguments){
        }

    }
}