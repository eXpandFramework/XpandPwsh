using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Reflection;
using System.Runtime.InteropServices;

namespace XpandPosh.Cmdlets.ResolveAssemblyDependencies{
    [Cmdlet(VerbsDiagnostic.Resolve, "AssemblyDependencies")]
    [CmdletBinding]
    public class ResolveAssemblyDependencies : PSCmdlet{
        [Parameter(Mandatory = true,Position = 0)]
        public string AssemblyFile{ get; set; }

        public ResolveDependenciesOutputType OutputType{ get; set; }

        [Parameter(Position = 3)]
        public SwitchParameter SkipGAC{ get; set; }
        [Parameter(Position = 2)]
        public string[] Locations{ get; set; }=new string[0];

        protected override void ProcessRecord(){
            base.ProcessRecord();
            var sources = Locations.Concat(new[]{Path.GetDirectoryName(AssemblyFile)}).ToArray();

            Assembly ResolveEventHandler(object sender, ResolveEventArgs args){
                var name = args.Name;
                var indexOf = name.IndexOf(",", StringComparison.Ordinal);
                if (indexOf > 0) name = args.Name.Substring(0, indexOf);

                foreach (var location in sources){
                    var path = $"{Path.Combine(location, name)}.dll";
                    if (File.Exists(path)) return Assembly.LoadFile(path);
                }

                return null;
            }

            AppDomain.CurrentDomain.AssemblyResolve += ResolveEventHandler;
            Resolve();
            AppDomain.CurrentDomain.AssemblyResolve -= ResolveEventHandler;
        }

        private void Resolve(){
            var references = new HashSet<string>();
            var pending = new Queue<AssemblyName>();

            pending.Enqueue(Assembly.LoadFile(AssemblyFile).GetName());
            while (pending.Count > 0){
                var assemblyName = pending.Dequeue();
                var value = assemblyName.ToString();
                if (references.Contains(value)){
                    continue;
                }

                references.Add(value);
                try{
                    var assembly = Assembly.Load(assemblyName);
                    if (assembly != null){
                        foreach (var sub in assembly.GetReferencedAssemblies()){
                            pending.Enqueue(sub);
                        }

                        foreach (var type in assembly.GetTypes()){
                            foreach (var method in type.GetMethods(BindingFlags.Static | BindingFlags.Public |
                                                                   BindingFlags.NonPublic)){
                                var customAttribute =
                                    (DllImportAttribute) Attribute.GetCustomAttribute(method, typeof(DllImportAttribute));
                                if (customAttribute != null && !references.Contains(customAttribute.Value)){
                                    references.Add(customAttribute.Value);
                                }
                            }
                        }
                    }
                }
                catch (Exception ex){
                    WriteError(new ErrorRecord(ex, ex.GetHashCode().ToString(), ErrorCategory.InvalidOperation,
                        assemblyName.ToString()));
                }
            }

            var sortedRefs = references.OrderBy(s => s);
            if (OutputType == ResolveDependenciesOutputType.Assembly){
                var assemblies = AppDomain.CurrentDomain.GetAssemblies()
                    .Where(assembly => !SkipGAC || !assembly.GlobalAssemblyCache)
                    .ToArray();
                WriteObject(sortedRefs.Select(s => assemblies.FirstOrDefault(_ => _.GetName().ToString() == s)), true);
            }
            else if(OutputType==ResolveDependenciesOutputType.AssemblyName){
                WriteObject(sortedRefs.Select(s => {
                    var indexOf = s.IndexOf(",", StringComparison.Ordinal);
                    return indexOf > -1 ? s.Substring(0, indexOf) : s;
                }),true);
            }
            else{
                WriteObject(sortedRefs,true);
            }
        }
    }

    public enum ResolveDependenciesOutputType{
        AssemblyName,
        AssemblyFullName,
        Assembly
    }
}