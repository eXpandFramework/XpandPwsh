using System;
using System.Linq;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using JetBrains.Annotations;
using XpandPwsh.CmdLets;
using XpandPwsh.Cmdlets.GitHub.GetGitHubCommitIssue;

namespace XpandPwsh.Cmdlets.GitHub.PublishGitHubRelease{
    [CmdletBinding(SupportsShouldProcess = true)]
    [Cmdlet(VerbsCommon.New, "GithubReleaseNotes",SupportsShouldProcess = true)]
    [OutputType(typeof(string))]
    [CmdLetTag(CmdLetTag.GitHub,CmdLetTag.Reactive,CmdLetTag.RX)][PublicAPI]
    public class NewGitHubReleaseNotes : XpandCmdlet{
        [Parameter()]
        public IReleaseNotesTemplate ReleaseNotesTemplate{ get; set; } = GitHub.PublishGitHubRelease.ReleaseNotesTemplate.Default;

        [Parameter(Mandatory = true)]
        public ICommitIssues[] CommitIssues{ get; set; }

        protected override  Task ProcessRecordAsync(){
            return Observable.Return(string.Join(Environment.NewLine,ReleaseNotesTemplate.Parts
                    .Select(GetBody)
                    .Where(s => !string.IsNullOrWhiteSpace(s))))
                .WriteObject(this)
                .ToTask();
        }

        private  string GetBody( ITemplatePart templatePart){
            var body = string.Join(Environment.NewLine, CommitIssues
                .Where(tuple => templatePart.Labels.Intersect(tuple.Issues.SelectMany(issue => issue.Labels).Select(label => label.Name)).Any())
                .Select(tuple => {
                    var commitMessage = Regex.Replace(tuple.GitHubCommit.Commit.Message, @"(#\d*)", "", RegexOptions.IgnoreCase);
                    var numbers = string.Join(" ",tuple.Issues.Select(issue => $"#[{issue.Number}]({tuple.Repository2.HtmlUrl}/issues/{issue.Number})"));
                    return $"1. {numbers} {commitMessage}";
                }));
            return !string.IsNullOrWhiteSpace(body) ? string.Join(Environment.NewLine, templatePart.Header, body, templatePart.Footer) : null;
        }
    }

}