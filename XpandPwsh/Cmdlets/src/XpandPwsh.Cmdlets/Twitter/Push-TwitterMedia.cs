using System.Collections.Generic;
using System.IO;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using JetBrains.Annotations;
using LinqToTwitter;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.Twitter{
    [Cmdlet(VerbsCommon.Push, "TwitterMedia")]
    [CmdletBinding]
    [CmdLetTag(CmdLetTag.Reactive, CmdLetTag.RX,CmdLetTag.Linq2Twitter)]
    [PublicAPI]
    public class PushTwitterMedia : XpandCmdlet{
        [Parameter(Mandatory = true,Position = 1,ValueFromPipeline = true)]
        public FileInfo Media{ get; set; }
        [Parameter(Mandatory = true,Position = 0)]
        public TwitterContext TwitterContext{ get; set; }

        List<FileInfo> _files=new List<FileInfo>();
        protected override Task BeginProcessingAsync(){
            _files.Add(Media);
            return base.BeginProcessingAsync();
        }

        protected override Task EndProcessingAsync(){
            return _files.ToObservable()
                .SelectMany(info => {
                    var mediaCategory = MediaCategory;
                    if (info.Extension.EndsWith("gif")){
                        mediaCategory = "tweet_gif";
                    }
                    return TwitterContext.UploadMediaAsync(File.ReadAllBytes(info.FullName),
                        MimeSharp.Mime.Lookup(info.FullName), mediaCategory);
                })
                .HandleErrors(this)
                .WriteObject(this)
                .ToTask();
        }

        [ValidateSet("tweet_image", "tweet_video", "tweet_gif", "amplify_video")]
        [Parameter]
        public string MediaCategory{ get; set; } = "tweet_image";
    }
}