using System.Linq;
using System.Management.Automation;
using System.Threading.Tasks;
using Fasterflect;

namespace XpandPosh.CmdLets{
    public abstract class XpandCmdlet:AsyncCmdlet{
        
        public ActionPreference ErrorAction => this.ErrorAction();

        protected override Task BeginProcessingAsync(){
            GetCallerPreference();
            return base.BeginProcessingAsync();
        }

        protected virtual void GetCallerPreference(){
            CmdletExtensions.GetCallerPreference(this);
        }


    }
}