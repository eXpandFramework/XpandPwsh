
function Read-AssemblyDefinition {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)]
        [string]$Path,
        [System.IO.FileInfo[]]$AssemblyList
    )
    
    begin {
        
    }
    
    process {
        
        $p=[Mono.Cecil.ReaderParameters]::new()
        $p.AssemblyResolver=New-AssemblyResolver -AssemblyList $AssemblyList -Path $Path
        [Mono.Cecil.AssemblyDefinition]::ReadAssembly($Path,$p)
    }
    
    end {
        
    }
}