function Get-AssemblyVersion {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#monocecil"))]
    param (
        [parameter(ValueFromPipeline,Mandatory,ParameterSetName="File")]
        [System.IO.FileInfo]$Assembly,
        [parameter(ValueFromPipeline,Mandatory,ParameterSetName="Mono")]
        $AssemblyDefinition
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        if ($PSCmdlet.ParameterSetName -eq "File"){
            Use-MonoCecil|Out-Null
        }
    }
    
    process {
        if ($PSCmdlet.ParameterSetName -eq "File"){
            Use-Object($asm=Read-AssemblyDefinition $Assembly.FullName){
                Get-AssemblyVersion -AssemblyDefinition $asm
            }
        }
        $AssemblyDefinition.Name.Version
    }
    end {
        
    }
}