function Get-AssemblyVersion {
    [CmdletBinding(DefaultParameterSetName="File")]
    [CmdLetTag(("#dotnet","#monocecil"))]
    param (
        [parameter(ValueFromPipeline,Mandatory,ParameterSetName="File",Position=0)]
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
            try {
                Use-Object($asm=Read-AssemblyDefinition $Assembly.FullName){
                    Get-AssemblyVersion -AssemblyDefinition $asm
                }
            }
            catch {
                $LASTEXITCODE=0
                [System.Diagnostics.FileVersionInfo]::GetVersionInfo($Assembly.FullName).FileVersion
            }
        }
        else{
            $AssemblyDefinition.Name.Version
        }
    }
    end {
        
    }
}