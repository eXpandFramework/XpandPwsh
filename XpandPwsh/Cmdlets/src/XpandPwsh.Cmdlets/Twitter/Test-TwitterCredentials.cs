using System.Linq;
using System.Management.Automation;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using JetBrains.Annotations;
using LinqToTwitter;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.Twitter{
    [Cmdlet(VerbsDiagnostic.Test, "TwitterCredentials")]
    [CmdletBinding]
    [CmdLetTag(CmdLetTag.Reactive, CmdLetTag.RX,CmdLetTag.Linq2Twitter)]
    [PublicAPI]
    public class TestTwitterCredentials : XpandCmdlet{
        [Parameter(Mandatory = true,Position = 0)]
        public TwitterContext TwitterContext{ get; set; }

        protected override Task ProcessRecordAsync(){
            
            return TwitterContext.Account.Where(account => account.Type==AccountType.VerifyCredentials)
                .SingleOrDefaultAsync().ToObservable()
                .HandleErrors(this)
                .WriteObject(this)
                .ToTask();

        }

    }
}