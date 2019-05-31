using namespace Mono.Cecil;
class AssemblyResolver : DefaultAssemblyResolver{
    [String] $Path
    AssemblyResolver([String] $Path) {
        $this.Path = $Path
    }
    
    [AssemblyDefinition] Resolve([AssemblyNameReference]$name, [ReaderParameters]$parameters){
        try {
            return ([DefaultAssemblyResolver]$this).Resolve()
        }
        catch {
            $assemblyName=$name.Name
            $comma=$assemblyName.IndexOf(",")
            if ($comma -gt -1)     {
                $assemblyName=$assemblyName.Substring(0,$comma)
            }
            $dir=$this.Path
            return [AssemblyDefinition]::ReadAssembly("$dir\$assemblyName.dll")
        }
    }
}