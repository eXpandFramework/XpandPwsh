﻿using System.Collections.Generic;

namespace XpandPwsh.Cmdlets.GitHub.PublishGitHubRelease{
    public interface ITemplatePart{
        IList<string> Labels{ get; }
        string Header{ get; set; }
        string Footer{ get; set; }
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