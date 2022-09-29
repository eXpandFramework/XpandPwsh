function Set-AssemblySignature {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#monocecil"))]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [System.IO.FileInfo]$Assembly,
        [parameter(Mandatory)]
        [System.IO.FileInfo]$SnkFile,
        [string]$AssemblyReference,
        [string]$ResolverPath
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        Use-MonoCecil|Out-Null        
    }
    
    process {
        $token=$null
        if ($AssemblyReference){
            $asm=Read-AssemblyDefinition $Assembly.FullName
            $token=$asm.Name.publicKeyToken
            $asm.Dispose()
        }
        $readerParams = New-Object Mono.Cecil.ReaderParameters
        $readerParams.AssemblyResolver=New-AssemblyResolver  -Path $ResolverPath
        $readerParams.ReadWrite = $true
        Use-Object([Mono.Cecil.AssemblyDefinition]$asm=[Mono.Cecil.AssemblyDefinition]::ReadAssembly($Assembly,$readerParams)){
            $writeParams = New-Object Mono.Cecil.WriterParameters
            $key = [System.IO.File]::ReadAllBytes($snkFile)
            $writeParams.StrongNameKeyPair = [System.Reflection.StrongNameKeyPair]($key)
            if ($token){
                $moduleReferences= $asm.MainModule.AssemblyReferences
                $moduleReferences.ToArray()|Where-Object{$_.Name -in $AssemblyReference }|ForEach-Object{
                    $AsemblyNameReference=$_
                    $AsemblyNameReference.PublicKeyToken=$token
                }
            }
            $asm.Write($writeParams)
        }
    }
    end {
        
    }
}