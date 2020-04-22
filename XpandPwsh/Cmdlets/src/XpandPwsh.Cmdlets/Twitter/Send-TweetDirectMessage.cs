using System;
using System.Collections.Generic;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using JetBrains.Annotations;
using LinqToTwitter;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.Twitter{
    [Cmdlet(VerbsCommunications.Send, "TweetDirectMessage")]
    [CmdletBinding]
    [CmdLetTag(CmdLetTag.Reactive, CmdLetTag.RX,CmdLetTag.Linq2Twitter)]
    [PublicAPI]
    public class SendTweetDirectMessage : XpandCmdlet{
        [Parameter(Mandatory = true,Position = 0)]
        public TwitterContext TwitterContext{ get; set; }
        [Parameter(Mandatory = true,ValueFromPipeline = true,Position = 1)]
        public User User{ get; set; }
        [Parameter(Mandatory = true,Position = 2)]
        public string Text{ get; set; }

        private List<User> _users=new List<User>();

        protected override Task EndProcessingAsync(){
            return _users.ToObservable()
                .SelectMany(user => TwitterContext.NewDirectMessageEventAsync(Convert.ToUInt64(user.UserIDResponse),Text))
                .HandleErrors(this)
                .WriteObject(this)
                .ToTask();
        }

        protected override Task ProcessRecordAsync(){
            _users.Add(User);
            return base.ProcessRecordAsync();
        }

    }
}