using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Reflection;

namespace XpandPwsh.Cmdlets.InvokeParallel{
    [Cmdlet(VerbsCommon.Get, "ReferenceConflict")]
    [CmdletBinding]
    public class GetReferenceConflict : PSCmdlet{
        [Parameter]
        public string Path{ get; set; } 

        [Parameter]
        public string Filter{ get; set; } = "*";
        [Parameter]
        public  SwitchParameter Recurse{ get; set; }
        protected override void ProcessRecord(){
            base.ProcessRecord();
            if (Path == null) Path = Environment.CurrentDirectory;
            
            var multipleVersions = GetReferencedAssembliesWithMultipleVersions(Path).ToArray();
            var pairs = multipleVersions.Select(tuples => new{
                tuples.Key, Conflicts = tuples.Select(tuple => new{Assembly = tuple.assembly, Reference = tuple.referenceASsembly})
            });
            var wildcardPattern = new WildcardPattern(Filter,WildcardOptions.Compiled|WildcardOptions.IgnoreCase);
            var results = pairs.Where(__ =>wildcardPattern.IsMatch(__.Key)).ToArray();
            if (results.Length == 1){
                WriteObject(results.First().Conflicts);
            }
            else{
                foreach (var pair in results){
                    WriteObject(pair);
                }
            }
        }

        public IEnumerable<IGrouping<string, (AssemblyName assembly, AssemblyName referenceASsembly)>> GetReferencedAssembliesWithMultipleVersions(string path){
            var assemblies = GetAllAssemblies(path);
            var references = GetReferencesFromAllAssemblies(assemblies);

            return references
                .GroupBy(r => r.referenceASsembly.Name)
                .Where(r => r.Select(t => t.referenceASsembly.FullName).Distinct().Count() > 1);
        }

        private IEnumerable<(AssemblyName assembly, AssemblyName referenceASsembly)> GetReferencesFromAllAssemblies(IEnumerable<Assembly> assemblies){
            return assemblies.SelectMany(GetReferencedAssemblies);
        }

        private  IEnumerable<(AssemblyName assembly, AssemblyName referenceASsembly)> GetReferencedAssemblies(Assembly asm){
            return asm.GetReferencedAssemblies().Select(refAsm => (asm.GetName(), refAsm));
        }

        private  IEnumerable<Assembly> GetAllAssemblies(string path){
            return GetFileNames(path, "*.dll", "*.exe")
                .Select(TryLoadAssembly)
                .Where(asm => asm != null);
        }

        private  IEnumerable<string> GetFileNames(string path, params string[] extensions){
            return extensions.SelectMany(ext => Directory.GetFiles(path, ext, Recurse ? SearchOption.AllDirectories : SearchOption.TopDirectoryOnly));
        }

        private  Assembly TryLoadAssembly(string filename){
            try{
                return Assembly.LoadFile(filename);
            }
            catch (BadImageFormatException){
                return null;
            }
        }
    }
}