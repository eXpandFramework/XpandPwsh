using System.Collections.Generic;
using System.Management.Automation;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using JetBrains.Annotations;
using LinqToTwitter;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.Twitter{
    [Cmdlet(VerbsCommunications.Send, "Retweet")]
    [CmdletBinding]
    [CmdLetTag(CmdLetTag.Reactive, CmdLetTag.RX,CmdLetTag.Linq2Twitter)]
    [PublicAPI]
    public class SendRetweet : XpandCmdlet{
        [Parameter(Mandatory = true,Position = 0)]
        public TwitterContext TwitterContext{ get; set; }
        [Parameter(Mandatory = true,ValueFromPipeline = true,Position = 1)]
        public Status Status{ get; set; }

        [ValidateSet(nameof(LinqToTwitter.TweetMode.Compat), nameof(LinqToTwitter.TweetMode.Extended))]
        public string TweetMode{ get; set; } = nameof(LinqToTwitter.TweetMode.Compat);

        private List<Media> _medias = new List<Media>();
        protected override Task ProcessRecordAsync(){
            return TwitterContext.RetweetAsync(Status.ID,EnumsNET.Enums.Parse<TweetMode>(TweetMode)).ToObservable()
                .HandleErrors(this)
                .WriteObject(this)
                .ToTask();

        }

    }
}