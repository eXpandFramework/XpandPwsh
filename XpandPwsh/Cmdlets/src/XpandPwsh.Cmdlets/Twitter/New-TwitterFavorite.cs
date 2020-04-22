using System.Collections.Generic;
using System.Management.Automation;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using JetBrains.Annotations;
using LinqToTwitter;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.Twitter{
    [Cmdlet(VerbsCommon.New, "TwitterFavorite")]
    [CmdletBinding]
    [CmdLetTag(CmdLetTag.Reactive, CmdLetTag.RX,CmdLetTag.Linq2Twitter)]
    [PublicAPI]
    public class NewTwitterFavorite : XpandCmdlet{

        [Parameter(Mandatory = true,Position = 0)]
        public TwitterContext TwitterContext{ get; set; }
        [Parameter(Mandatory = true,ValueFromPipeline = true,Position = 1)]
        public Status Status{ get; set; }

        private List<Media> _medias = new List<Media>();
        protected override Task ProcessRecordAsync(){
            return TwitterContext.CreateFavoriteAsync(Status.ID).ToObservable()
                .HandleErrors(this)
                .WriteObject(this)
                .ToTask();

        }
    }
}
