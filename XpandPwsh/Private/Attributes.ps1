using namespace Mono.Cecil;
class CmdLetTag:Attribute {
    CmdLetTag(){
        $this.Tags=@()
    }
    CmdLetTag([string[]]$Tags){
        $this.Tags=$Tags
    }
    [string[]]$Tags
}
