function Set-AssemblySignature {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#monocecil"))]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [System.IO.FileInfo]$Assembly,
        [parameter(Mandatory)]
        [System.IO.FileInfo]$SnkFile,
        [string[]]$AssemblyReference
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        Use-MonoCecil|Out-Null        
    }
    
    process {
        if ($AssemblyReference){
            $token=Get-AssemblyPublicKeyToken $Assembly
        }
        $readerParams = New-Object Mono.Cecil.ReaderParameters
        $readerParams.ReadWrite = $true
        Use-Object([Mono.Cecil.AssemblyDefinition]$asm=[Mono.Cecil.AssemblyDefinition]::ReadAssembly($Assembly,$readerParams)){
            $writeParams = New-Object Mono.Cecil.WriterParameters
            $key = [System.IO.File]::ReadAllBytes($snkFile)
            $writeParams.StrongNameKeyPair = [System.Reflection.StrongNameKeyPair]($key)
            if ($token){
                $moduleReferences.Name = $asm.MainModule.AssemblyReferences
                $moduleReferences.ToArray()|Where-Object{$_.Name -in $AssemblyReference }|ForEach-Object{
                    $AsemblyNameReference=$_
                    $moduleReferences.Remove($_) | Out-Null   
                    $culture=$AsemblyNameReference.Culture
                    if (!$culture){
                        $culture="null"
                    }
                    $newRef.FullName=[AssemblyNameReference]::Parse("$($AsemblyNameReference.Name), Version=$($AsemblyNameReference.Version), Culture=$culture, PublicKeyToken=$token")
                    $moduleReferences.Add($newRef)
                }
            }
            $asm.Write($writeParams)
        }
    }
    end {
        
    }
}