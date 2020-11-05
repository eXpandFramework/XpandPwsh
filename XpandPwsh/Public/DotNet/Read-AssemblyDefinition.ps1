
function Read-AssemblyDefinition {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#dotnetcore","#monocecil"))]
    param (
        [parameter(ValueFromPipeline)]
        [string]$Path,
        [System.IO.FileInfo[]]$AssemblyList=@(),
        [switch]$ReadWrite,
        [switch]$ReadSymbols
    )
    
    begin {
        Use-MonoCecil|Out-Null
    }
    
    process {
        
        $p=[Mono.Cecil.ReaderParameters]::new()
        $p.ReadWrite=$ReadWrite
        $p.ReadSymbols=$SkipSymbols
        $p.AssemblyResolver=New-AssemblyResolver -AssemblyList $AssemblyList -Path $Path
        [Mono.Cecil.AssemblyDefinition]::ReadAssembly($Path,$p)
    }
    
    end {
        
    }
}