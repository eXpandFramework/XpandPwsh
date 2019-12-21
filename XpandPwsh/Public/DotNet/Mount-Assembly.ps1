function Mount-Assembly {
    [CmdletBinding()]
    param (
        [parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        $Assembly
    )
    
    begin {
        
    }
    
    process {
        if ($PSVersionTable.Psedition -eq "Core"){
            [System.Runtime.Loader.AssemblyLoadContext]::Default.LoadFromAssemblyPath($Assembly)
        }
        else{
            $bytes = [System.IO.File]::ReadAllBytes($Assembly)
            [System.Reflection.Assembly]::Load($bytes)
        }    
    }
    
    end {
        
    }
}