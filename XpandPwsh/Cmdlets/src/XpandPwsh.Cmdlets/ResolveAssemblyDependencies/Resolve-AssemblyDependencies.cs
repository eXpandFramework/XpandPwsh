using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Reflection;
using System.Runtime.InteropServices;
using JetBrains.Annotations;

namespace XpandPwsh.Cmdlets.ResolveAssemblyDependencies{
    [Cmdlet(VerbsDiagnostic.Resolve, "AssemblyDependencies")]
    [CmdletBinding]
    [CmdLetTag()][PublicAPI]
    public class ResolveAssemblyDependencies : PSCmdlet{
        [Parameter(Mandatory = true,Position = 0)]
        public string AssemblyFile{ get; set; }

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

            var file = Assembly.LoadFile(AssemblyFile);
            WriteObject(file);
            pending.Enqueue(file.GetName());
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
                        WriteObject(assembly);
                        foreach (var sub in assembly.GetReferencedAssemblies()){
                            pending.Enqueue(sub);
                        }

                        foreach (var type in assembly.GetTypes()){
                            foreach (var method in type.GetMethods(BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic)){
                                var customAttribute = (DllImportAttribute) Attribute.GetCustomAttribute(method, typeof(DllImportAttribute));
                                if (customAttribute != null && !references.Contains(customAttribute.Value)){
                                    references.Add(customAttribute.Value);
                                }
                            }
                        }
                    }
                }
                catch (Exception ex){
                    WriteError(new ErrorRecord(ex, ex.GetHashCode().ToString(), ErrorCategory.InvalidOperation,assemblyName.ToString()));
                }
            }
        }
    }
}