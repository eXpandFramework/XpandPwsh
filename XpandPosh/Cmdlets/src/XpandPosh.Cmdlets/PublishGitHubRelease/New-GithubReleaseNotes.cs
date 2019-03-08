using System;
using System.Linq;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using XpandPosh.Cmdlets.GetGitHubCommitIssue;
using XpandPosh.CmdLets;

namespace XpandPosh.Cmdlets.PublishGitHubRelease{
    [CmdletBinding(SupportsShouldProcess = true)]
    [Cmdlet(VerbsCommon.New, "GithubReleaseNotes",SupportsShouldProcess = true)]
    [OutputType(typeof(string))]
    public class NewGitHubReleaseNotes : GitHubCmdlet{
        
        [Parameter(Mandatory = true)]
        public string Repository1{ get; set; }
        [Parameter(Mandatory = true)]
        public string Repository2{ get; set; }
        [Parameter]
        public string Header{ get; set; }
        
        [Parameter]
        public ICommitIssues[] CommitIssues{ get; set; }
        [Parameter()]
        public IReleaseNotesTemplate ReleaseNotesTemplate{ get; set; } = Cmdlets.PublishGitHubRelease.ReleaseNotesTemplate.Default;
        
        protected override  Task ProcessRecordAsync(){
            return Observable.Return(string.Join(Environment.NewLine,ReleaseNotesTemplate.Parts.Select(GetBody)))
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
            return !string.IsNullOrEmpty(body) ? $"{Header}{Environment.NewLine}{body}{Environment.NewLine}" : null;
        }
    }

}