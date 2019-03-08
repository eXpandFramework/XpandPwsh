using System.Collections.Generic;

namespace XpandPosh.Cmdlets.PublishGitHubRelease{
    public interface ITemplatePart{
        IList<string> Labels{ get; }
    }

    public class TemplatePart : ITemplatePart{
        public TemplatePart(){
            Labels = new List<string>();
        }

        public string Header{ get; set; }
        public string Footer{ get; set; }
        public IList<string> Labels{ get; }
    }
}