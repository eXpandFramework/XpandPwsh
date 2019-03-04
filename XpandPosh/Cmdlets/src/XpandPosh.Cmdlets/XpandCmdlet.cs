using System.Linq;
using System.Management.Automation;
using System.Threading.Tasks;
using Fasterflect;

namespace XpandPosh.CmdLets{
    public abstract class XpandCmdlet:AsyncCmdlet{
        private static MethodInvoker _getCmdletName;
        public ActionPreference ErrorAction => this.ErrorAction();

        protected XpandCmdlet(){
            var methodInfo = typeof(CmdletExtensions).GetMethods().First(info => info.Name.StartsWith(nameof(CmdletExtensions.GetCmdletName)));
            _getCmdletName = methodInfo.MakeGenericMethod(GetType()).DelegateForCallMethod();
        }
        protected override Task BeginProcessingAsync(){
            GetCallerPreference();
            return base.BeginProcessingAsync();
        }

        protected virtual void GetCallerPreference(){
            CmdletExtensions.GetCallerPreference(this);
        }

        public string GetName(){
            return (string) _getCmdletName.Invoke(null);
        }

    }
}