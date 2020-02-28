function Mount-Assembly {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#dotnetcore"))]
    param (
        [parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        $Assembly
    )
    
    begin {
        
    }
    
    process {
        $name=(Get-Item $Assembly).BaseName
        $loaded=Get-Assembly $name
        if (!$loaded){
            if ($PSVersionTable.Psedition -eq "Core"){
                [System.Runtime.Loader.AssemblyLoadContext]::Default.LoadFromAssemblyPath($Assembly)
            }
            else{
                $bytes = [System.IO.File]::ReadAllBytes($Assembly)
                [System.Reflection.Assembly]::Load($bytes)
            }    
        }
        else{
            $loaded
        }
    }
    
    end {
        
    }
}