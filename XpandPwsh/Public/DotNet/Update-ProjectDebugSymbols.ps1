function Update-ProjectDebugSymbols {
    [CmdletBinding()]
    [CmdLetTag("#visualstudio")]
    param (
        [parameter(Mandatory)]
        [xml]$CSProj,
        [ValidateSet("pdbonly","full")]
        $DebugType    
    )
    
    begin {
    }
    
    process {
        Update-ProjectProperty $CSProj DebugSymbols true
        Update-ProjectProperty $CSProj DebugType pdbonly
    }
    
    end {
    }
}