using System;
using System.IO;
using System.Reflection;
using XpandPosh.CmdLets;

namespace XpandPosh.Cmdlets.Nuget{
    public abstract class NugetCmdlet : XpandCmdlet{
        static NugetCmdlet(){
            AppDomain.CurrentDomain.AssemblyResolve+=CurrentDomainOnAssemblyResolve;
        }

        private static Assembly CurrentDomainOnAssemblyResolve(object sender, ResolveEventArgs args){
            if (args.Name.Contains("Newton")){
                return Assembly.LoadFile(
                    $@"{Path.GetDirectoryName(typeof(GetNugetPackageSearchMetadata.GetNugetPackageSearchMetadata).Assembly.Location)}\Newtonsoft.Json.dll");
            }
            return null;
        }
    }
}