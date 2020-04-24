using System.Linq;
using System.Management.Automation;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using JetBrains.Annotations;
using LinqToTwitter;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.Twitter{
    [Cmdlet(VerbsCommon.Find, "TwitterUser")]
    [CmdletBinding]
    [CmdLetTag(CmdLetTag.Reactive, CmdLetTag.RX,CmdLetTag.Linq2Twitter)]
    [PublicAPI]
    public class FindTwitterUser : XpandCmdlet{
        [Parameter(Mandatory = true,Position = 0)]
        public TwitterContext TwitterContext{ get; set; }
        [Parameter(Mandatory = true,ValueFromPipeline = true,Position = 1)]
        public string[] ScreenName{ get; set; }

        protected override Task ProcessRecordAsync(){
            var screenNameList = string.Join(",",ScreenName);
            return TwitterContext.User.Where(user => user.TweetMode==TweetMode.Extended&&user.Type==UserType.Lookup&&user.ScreenNameList==screenNameList)
                .ToListAsync().ToObservable()
                .HandleErrors(this)
                .WriteObject(this)
                .ToTask();

        }

    }
}