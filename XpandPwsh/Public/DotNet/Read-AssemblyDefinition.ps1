
function Read-AssemblyDefinition {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)]
        [string]$Path,
        [System.IO.FileInfo[]]$AssemblyList
    )
    
    begin {
        . "$(Get-XpandPwshDirectoryName)\private\AssemblyResolver.ps1"
    }
    
    process {
        
        $p=[Mono.Cecil.ReaderParameters]::new()
        if ($AssemblyList){
            $p.AssemblyResolver=[AssemblyResolver]::new($AssemblyList)
        }
        else{
            $p.AssemblyResolver=[AssemblyResolver]::new($Path)
        }
        
        [Mono.Cecil.AssemblyDefinition]::ReadAssembly($Path,$p)
    }
    
    end {
        
    }
}