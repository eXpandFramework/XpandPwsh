
function Read-AssemblyDefinition {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#dotnetcore","#monocecil"))]
    param (
        [parameter(ValueFromPipeline)]
        [string]$Path,
        [System.IO.FileInfo[]]$AssemblyList=@(),
        [switch]$ReadOnly,
        [switch]$SkipSymbols
    )
    
    begin {
        Use-MonoCecil|Out-Null
    }
    
    process {
        
        $p=[Mono.Cecil.ReaderParameters]::new()
        $p.ReadWrite=!$ReadOnly
        $p.ReadSymbols=!$SkipSymbols
        $p.AssemblyResolver=New-AssemblyResolver -AssemblyList $AssemblyList -Path $Path
        [Mono.Cecil.AssemblyDefinition]::ReadAssembly($Path,$p)
    }
    
    end {
        
    }
}