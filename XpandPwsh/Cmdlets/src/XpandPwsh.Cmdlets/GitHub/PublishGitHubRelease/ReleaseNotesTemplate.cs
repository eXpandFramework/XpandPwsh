using System.Collections.Generic;

namespace XpandPwsh.Cmdlets.GitHub.PublishGitHubRelease{
    public interface IReleaseNotesTemplate{
        IList<ITemplatePart> Parts{ get;  }
    }

    public class ReleaseNotesTemplate : IReleaseNotesTemplate{
        public static ReleaseNotesTemplate Default{
            get{
                var instance = new ReleaseNotesTemplate();
                instance.Parts.Add(new TemplatePart(){Labels = {"Enhancements"}, Header = @"### Enhacements"});
                instance.Parts.Add(new TemplatePart(){Labels = {"Bug"}, Header = @"### Bugs"});
                instance.Parts.Add(new TemplatePart(){Labels = {"BreakingChange"}, Header = @"### Breaking Changes"});
                return instance;
            }
        }


        private ReleaseNotesTemplate(){
        }


        
        public IList<ITemplatePart> Parts{ get;  }=new List<ITemplatePart>();
    }
}