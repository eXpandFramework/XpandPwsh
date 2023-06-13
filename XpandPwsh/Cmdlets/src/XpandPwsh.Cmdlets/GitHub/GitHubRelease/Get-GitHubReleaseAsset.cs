using System;
using System.IO;
using System.Management.Automation;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using JetBrains.Annotations;
using Octokit;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.GitHub.GitHubRelease{
    [CmdletBinding()]
    [Cmdlet(VerbsCommon.Pop, "GitHubReleaseAsset")]
    [CmdLetTag(CmdLetTag.GitHub,CmdLetTag.Reactive,CmdLetTag.RX)][PublicAPI]
    public class PopGitHubReleaseAsset : GitHubCmdlet{
        [Parameter(Mandatory = true)]
        public string Repository{ get; set; }
        [Parameter(Mandatory = true)]
        public string AssetName{ get; set; }
        
        public string DownloadPath{ get; set; } = Path.GetTempPath();
        [Parameter]
        public SwitchParameter Latest{ get; set; }
        
        protected override Task ProcessRecordAsync(){
            return  this.Invoke<Release>($"Get-GitHubRelease -Repository {Repository} -{nameof(Organization)} {Organization} -{nameof(Latest)} -{nameof(Token)} {Token}").ToObservable()
                .SelectMany(release => release.Assets).Where(asset => new WildcardPattern(AssetName,WildcardOptions.Compiled|WildcardOptions.IgnoreCase).IsMatch(asset.Name))
                .SelectMany(asset => {
                    var httpClient = new HttpClient();
                    httpClient.DefaultRequestHeaders.Add("Accept","application/octet-stream");
                    httpClient.DefaultRequestHeaders.Add("X-GitHub-Api-Version","2022-11-28");
                    httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", Token);
                    httpClient.DefaultRequestHeaders.UserAgent.Add(new ProductInfoHeaderValue(nameof(GitHubClient), typeof(GitHubClient).Assembly.GetName().Version!.ToString()));
                    return httpClient.GetByteArrayAsync($"https://api.github.com/repos/{Organization}/{Repository}/releases/assets/{asset.Id}").ToObservable()
                        .Do(bytes => File.WriteAllBytes($"{DownloadPath}\\{asset.Name}", bytes));
                }).ToTask();
                        
        }
    }
}