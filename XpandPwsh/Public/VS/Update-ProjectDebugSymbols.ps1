function Update-ProjectDebugSymbols {
    [CmdletBinding()]
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