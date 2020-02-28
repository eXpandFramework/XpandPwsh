function Get-SymbolSources {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#dotnetcore"))]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [System.IO.FileInfo]$pdb,
        [parameter()]
        [string]$dbgToolsPath = "$PSScriptRoot\..\..\Private\srcsrv"
    )
    
    begin {
        if (!(test-path $dbgToolsPath)) {
            throw "srcsrv is invalid"
        }
    }
    
    process {
        & "$dbgToolsPath\srctool.exe" $pdb
    }
    
    end {            
    }
}
