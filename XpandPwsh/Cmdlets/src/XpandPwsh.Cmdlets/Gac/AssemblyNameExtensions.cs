using System.Reflection;

namespace XpandPwsh.Cmdlets.Gac{
    public static class AssemblyNameExtensions{
        public static string GetFullyQualifiedName(this AssemblyName assemblyName){
            if (assemblyName.ProcessorArchitecture == ProcessorArchitecture.None)
                return assemblyName.FullName;
            return assemblyName.FullName + ", ProcessorArchitecture=" +
                   assemblyName.ProcessorArchitecture.ToString().ToLower();
        }

        public static bool IsFullyQualified(this AssemblyName assemblyName){
            return !string.IsNullOrEmpty(assemblyName.Name) && assemblyName.Version != null &&
                   assemblyName.CultureInfo != null && assemblyName.GetPublicKeyToken() != null;
        }
    }
}