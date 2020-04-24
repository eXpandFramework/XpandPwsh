using System.Linq;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using JetBrains.Annotations;
using LinqToTwitter;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.Twitter{
    [Cmdlet(VerbsCommon.Find, "Tweet")]
    [CmdletBinding]
    [CmdLetTag(CmdLetTag.Reactive, CmdLetTag.RX,CmdLetTag.Linq2Twitter)]
    [PublicAPI]
    public class FindTweet : XpandCmdlet{
        [Parameter(Mandatory = true,Position = 0)]
        public TwitterContext TwitterContext{ get; set; }
        [Parameter(Mandatory = true,ValueFromPipeline = true,Position = 1)]
        public string ScreenName{ get; set; }

        [Parameter]
        public string MatchPattern{ get; set; } = ".*";

        protected override Task ProcessRecordAsync(){
            
            return TwitterContext.Status.Where(status => status.Type==StatusType.User&&status.ScreenName==ScreenName)
                .ToListAsync().ToObservable().SelectMany(list => list)
                .Where(status => new Regex(MatchPattern).IsMatch(status.Text))
                .HandleErrors(this)
                .WriteObject(this)
                .ToTask();

        }

    }
}