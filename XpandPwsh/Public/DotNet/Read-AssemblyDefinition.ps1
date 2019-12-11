
function Read-AssemblyDefinition {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [string]$Path
    )
    
    begin {
        . "$(Get-XpandPwshDirectoryName)\private\AssemblyResolver.ps1"
    }
    
    process {
        
        $p=[Mono.Cecil.ReaderParameters]::new()
        $p.AssemblyResolver=[AssemblyResolver]::new($Path)
        [Mono.Cecil.AssemblyDefinition]::ReadAssembly($Path,$p)
    }
    
    end {
        
    }
}