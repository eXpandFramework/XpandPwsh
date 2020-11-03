function Set-AssemblyVersion {
    [CmdletBinding(DefaultParameterSetName = "Parent")]
    [CmdLetTag(("#dotnet","#dotnetcore","#monocecil"))]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [System.IO.FileInfo]$Assembly,
        [version]$NewVersion,
        [System.IO.FileInfo]$KeyPath
    )
    
    begin {
        $PSCmdlet | Write-PSCmdLetBegin
    }
    
    process {
        Use-Object($asm=Read-AssemblyDefinition $Assembly.FullName){
            $asm.Name.Version=$NewVersion
            $writeParams = New-Object Mono.Cecil.WriterParameters
            $writeParams.WriteSymbols = $asm.MainModule.hassymbols
            if ($KeyPath){
                $key = [System.Io.File]::ReadAllBytes([System.IO.Path]::GetFullPath($KeyPath.FullName))
                $writeParams.StrongNameKeyPair = [System.Reflection.StrongNameKeyPair]($key)
            }
            $asm.write($writeParams)|Out-Null
        }
    }
    
    end {
        
    }
}