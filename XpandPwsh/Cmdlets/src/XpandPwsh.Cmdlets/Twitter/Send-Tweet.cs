using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using JetBrains.Annotations;
using LinqToTwitter;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.Twitter{
    [Cmdlet(VerbsCommunications.Send, "Tweet")]
    [CmdletBinding]
    [CmdLetTag(CmdLetTag.Reactive, CmdLetTag.RX,CmdLetTag.Linq2Twitter)]
    [PublicAPI]
    public class SendTweet : XpandCmdlet{
        [Parameter(ValueFromPipeline = true,Position = 2)]
        public Media Media{ get; set; }
        [Parameter(Mandatory = true,Position = 0)]
        public TwitterContext TwitterContext{ get; set; }
        [Parameter(Mandatory = true,Position = 1)]
        public string Status{ get; set; }

        private List<Media> _medias = new List<Media>();
        protected override Task ProcessRecordAsync(){
            _medias.Add(Media);
            return Task.CompletedTask;
        }

        protected override Task EndProcessingAsync(){
            return TwitterContext.TweetAsync(Status,_medias.Select(media => media.MediaID)).ToObservable()
                .HandleErrors(this)
                .WriteObject(this)
                .ToTask();
        }
    }
}