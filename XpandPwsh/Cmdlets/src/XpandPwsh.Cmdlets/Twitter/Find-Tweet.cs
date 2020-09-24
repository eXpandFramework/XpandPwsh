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
        [Parameter(ValueFromPipeline = true,Position = 1)]
        public string ScreenName{ get; set; }

        [Parameter]
        [ValidateRange(0, 200)]
        public int Count{ get; set; } = 200;
        [Parameter]
        public string MatchPattern{ get; set; } = ".*";
        [Parameter]
        public SwitchParameter IncludeReplies{ get; set; } 
        [Parameter]
        public SwitchParameter IncludeRetweets{ get; set; }
        [Parameter]
        public StatusType StatusType{ get; set; }=StatusType.User; 
        [Parameter]
        public TweetMode TweetMode{ get; set; }=TweetMode.Compat; 

        protected override Task ProcessRecordAsync() 
            => TwitterContext.Status.Where(status => status.Type==StatusType&&status.ScreenName==ScreenName)
                .Where(status => Count==0||Count==status.Count)
                .Where(status => status.ExcludeReplies==!IncludeReplies)
                .Where(status => status.IncludeRetweets==IncludeRetweets)
                .Where(status => status.IncludeRetweets==IncludeRetweets)
                .Where(status => status.TweetMode==TweetMode)
                .ToListAsync().ToObservable().SelectMany(list => list)
                .Where(status => new Regex(MatchPattern).IsMatch(TweetMode==TweetMode.Compat? status.Text:status.FullText))
                .Select(status => status)
                .HandleErrors(this)
                .WriteObject(this)
                .ToTask();
    }
}