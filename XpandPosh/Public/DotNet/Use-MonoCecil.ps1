function Use-MonoCecil {
    [CmdletBinding()]
    param (
        [string]$OutputFolder = "$env:TEMP\$packageName",
        [switch]$All
    )
    
    begin {
    }
    
    process {
        $assemblies = 1
        if ($All) {
            $assemblies = 3
        }
        $mono = Use-NugetAssembly Mono.Cecil *v4.0 $OutputFolder | Select-Object -First $assemblies
        $monoPath = $mono | Select-Object -First 1 -ExpandProperty Location
        Add-Type @"
using Mono.Cecil;
public class MonoDefaultAssemblyResolver : DefaultAssemblyResolver{
    private readonly string _path;

    public MonoDefaultAssemblyResolver(string path){
        _path = path;
    }
    public override AssemblyDefinition Resolve(AssemblyNameReference name, ReaderParameters parameters){
        try{
            return base.Resolve(name, parameters);
        }
        catch (AssemblyResolutionException){
            var assemblyDefinition = AssemblyDefinition.ReadAssembly(string.Format(@"{1}\{0}.dll", name.Name,_path));
            return assemblyDefinition;
        }
    }
}
"@ -ReferencedAssemblies @("$monoPath")
        $mono
    }
    
    end {
    }
}