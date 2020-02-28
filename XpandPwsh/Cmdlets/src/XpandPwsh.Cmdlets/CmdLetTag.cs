using System;
using System.Linq;

namespace XpandPwsh.Cmdlets{
    public class CmdLetTag:Attribute{
        public const string DotNet = "#DotNet";
        public const string RX = "#RX";
        public const string Linq = "#Linq";
        public const string Reactive = "#Reactive";
        public const string GitHub = "#GitHub";
        public const string Nuget = "#Nuget";
        public string[] Tags{ get; }=Enumerable.Empty<string>().ToArray();

        public CmdLetTag(){
        }

        public CmdLetTag(params string[] tags){
            Tags = tags;
        }
    }
}