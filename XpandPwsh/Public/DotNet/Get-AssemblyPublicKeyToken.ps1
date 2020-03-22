function Get-AssemblyPublicKeyToken {
    [CmdletBinding()]
    [CmdLetTag("#dotnet")]
    param (
        [parameter(ValueFromPipeline,Mandatory,ParameterSetName="File")]
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
                Get-AssemblyPublicKeyToken -bytes $asm.Name.publicKeyToken
            }
        }
        
        (($Bytes|ForEach-Object{
            $_.ToString("x2")
        }) -join "").Trim("")
    }
    
    end {
    }
}