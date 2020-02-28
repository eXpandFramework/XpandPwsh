function Update-ProjectSign {
    [CmdletBinding()]
    [CmdLetTag("#visualstudio")]
    param (
        [parameter(Mandatory)]
        [xml]$CSProj,
        [parameter(Mandatory)]
        [string]$CSProjFileName,
        [parameter(Mandatory)]
        [string]$SnkFileName
    )
    
    begin {
    }
    
    process {
        Update-ProjectProperty $CSProj SignAssembly true
        $path=Get-RelativePath $CSProjFileName $SnkFileName
        Update-ProjectProperty $CSProj AssemblyOriginatorKeyFile $path
    }
    
    end {
    }
}