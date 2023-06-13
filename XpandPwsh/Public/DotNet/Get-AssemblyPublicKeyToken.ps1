function Get-AssemblyPublicKeyToken {
    [CmdletBinding(DefaultParameterSetName="File")]
    [CmdLetTag("#dotnet")]
    param (
        [parameter(ValueFromPipeline,Mandatory,ParameterSetName="File",Position=0)]
        [System.IO.FileInfo]$Assembly,
        [parameter(ValueFromPipeline,Mandatory,ParameterSetName="Raw")]
        [byte[]]$Bytes
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        Use-MonoCecil|Out-Null
    }
    
    process {
        if ($PSCmdlet.ParameterSetName -eq "File"){
            Use-Object($asm=Read-AssemblyDefinition $Assembly.FullName){
                if ($asm.Name.publicKeyToken){
                    Get-AssemblyPublicKeyToken -bytes $asm.Name.publicKeyToken
                }
                
            }
        }
        else{
            (($Bytes|ForEach-Object{
                $_.ToString("x2")
            }) -join "").Trim("")   
        }
    }
    
    end {
    }
}