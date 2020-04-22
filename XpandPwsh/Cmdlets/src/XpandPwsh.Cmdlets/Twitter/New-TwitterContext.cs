using System;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using JetBrains.Annotations;
using LinqToTwitter;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.Twitter{
    [Cmdlet(VerbsCommon.New, "TwitterContext")]
    [CmdletBinding]
    [CmdLetTag(CmdLetTag.Reactive, CmdLetTag.RX,CmdLetTag.Linq2Twitter)]
    [PublicAPI]
    public class NewTwitterContext : XpandCmdlet{

        [Parameter(Position = 0)]
        public string ConsumerKey{ get; set; } = $"{Environment.GetEnvironmentVariable("TwitterAPIKey")}";

        [Parameter(Position = 1)]
        public string ConsumerSecret{ get; set; } = $"{Environment.GetEnvironmentVariable("TwitterAPISecret")}";

        [Parameter(Position = 2)]
        public string OAuthToken{ get; set; } = $"{Environment.GetEnvironmentVariable("TwitterAccessToken")}";

        [Parameter(Position = 3)]
        public string OAuthTokenSecret{ get; set; } = $"{Environment.GetEnvironmentVariable("TwitterAccessTokenSecret")}";

        protected override Task ProcessRecordAsync(){
            if (OAuthToken == null){
                throw new ArgumentNullException(nameof(OAuthToken));
            }
            if (OAuthTokenSecret == null){
                throw new ArgumentNullException(nameof(OAuthTokenSecret));
            }
            if (ConsumerKey == null){
                throw new ArgumentNullException(nameof(ConsumerKey));
            }
            if (ConsumerSecret == null){
                throw new ArgumentNullException(nameof(ConsumerSecret));
            }
            var memoryCredentialStore = new InMemoryCredentialStore{
                ConsumerKey = ConsumerKey,
                ConsumerSecret = ConsumerSecret,
                OAuthToken = OAuthToken,
                OAuthTokenSecret = OAuthTokenSecret
            };
            var authorizer = new SingleUserAuthorizer{
                CredentialStore = memoryCredentialStore
            };
            return authorizer.AuthorizeAsync().ToObservable()
                .HandleErrors(this).Select(_ => new TwitterContext(authorizer))
                .WriteObject(this)
                .ToTask();

        }
    }
}
