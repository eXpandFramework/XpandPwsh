using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Reflection;
using System.Threading.Tasks;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.InvokeParallel{
    [Cmdlet(VerbsCommon.Get, "ReferenceConflict")]
    [CmdletBinding]
    public class GetReferenceConflict : PSCmdlet{
        [Parameter]
        public string Path{ get; set; }

        protected override void ProcessRecord(){
            base.ProcessRecord();
            if (Path == null) Path = Environment.CurrentDirectory;
            
            var multipleVersions = GetReferencedAssembliesWithMultipleVersions(Path).ToArray();
//            var maxNameLength = multipleVersions.SelectMany(t => t).Max(t => t.assembly.Name.Length);
            foreach (var x1 in multipleVersions.Select(tuples => new {
                tuples.Key,Conflicts = tuples.Select(tuple => new{Assembly = tuple.assembly, Reference = tuple.referenceASsembly})
            })) WriteObject(x1);
//            return;
//            foreach (var group in multipleVersions)
//            {
//                WriteObject($"Possible conflicts for {group.Key}:" );
//                foreach (var reference in group)
//                {
//                    WriteObject($"    {reference.assembly.Name.PadRight(maxNameLength)} references {reference.referenceASsembly.FullName}");
//                }
//            }
        }

        public static IEnumerable<IGrouping<string, (AssemblyName assembly, AssemblyName referenceASsembly)>> GetReferencedAssembliesWithMultipleVersions(string path){
            var assemblies = GetAllAssemblies(path);
            var references = GetReferencesFromAllAssemblies(assemblies);

            return references
                .GroupBy(r => r.referenceASsembly.Name)
                .Where(r => r.Select(t => t.referenceASsembly.FullName).Distinct().Count() > 1);
        }

        private static IEnumerable<(AssemblyName assembly, AssemblyName referenceASsembly)>
            GetReferencesFromAllAssemblies(IEnumerable<Assembly> assemblies){
            return assemblies.SelectMany(GetReferencedAssemblies);
        }

        private static IEnumerable<(AssemblyName assembly, AssemblyName referenceASsembly)> GetReferencedAssemblies(Assembly asm){
            return asm.GetReferencedAssemblies().Select(refAsm => (asm.GetName(), refAsm));
        }

        private static IEnumerable<Assembly> GetAllAssemblies(string path){
            return GetFileNames(path, "*.dll", "*.exe")
                .Select(TryLoadAssembly)
                .Where(asm => asm != null);
        }

        private static IEnumerable<string> GetFileNames(string path, params string[] extensions){
            return extensions.SelectMany(ext => Directory.GetFiles(path, ext, SearchOption.AllDirectories));
        }

        private static Assembly TryLoadAssembly(string filename){
            try{
                return Assembly.LoadFile(filename);
            }
            catch (BadImageFormatException){
                return null;
            }
        }
//        public static void Main(string[] args){
//            foreach (var path in GetPathsFromArgs(args)){
//                var references = AssemblyReference.GetReferencedAssembliesWithMultipleVersions(path);
//                OutputConflicts(Console.Out, references);
//            }
//        }

//        private static List<string> GetPathsFromArgs(string[] args){
//            var paths = new List<string>();
//
//            foreach (var arg in args)
//                if (arg.StartsWith("-")){
//                    if (arg.StartsWith("--")){
//                        // Long option.
//                    }
//                }
//                else if (arg.StartsWith("/")){
//                    // Windows option.
//                }
//                else{
//                    paths.Add(arg);
//                }
//
//            if (paths.Count == 0) paths.Add(Directory.GetCurrentDirectory());
//
//            return paths;
//        }
    }
}