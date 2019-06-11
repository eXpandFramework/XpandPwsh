namespace XpandPwsh.Cmdlets.Nuget.GetNugetPackage{
    public class NugetPackageAssembly:INugetPackageAssembly{
        public string Package{ get; set; }
        public string Version{ get; set; }
        public string DotNetFramework{ get; set; }
        public string File{ get; set; }
    }
    public interface INugetPackageAssembly{
        string Package{ get; set; }
        string Version{ get; set; }
        string DotNetFramework{ get; set; }
        string File{ get; set; }
    }
}