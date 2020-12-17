function Switch-AssemblyDependencyVersion {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet", "#dotnetcore", "#monocecil"))]
    param (
        [System.IO.FileInfo]$Assembly, 
        [version]$Version,
        [string]$ReferenceNameMatch,
        [System.IO.FileInfo]$SnkFile,
        [System.IO.FileInfo[]]$AssemblyList
    )
    
    begin {
        $PSCmdlet | Write-PSCmdLetBegin
        Use-MonoCecil|Out-Null
    }
    
    process {
        $moduleAssembly=Read-AssemblyDefinition $Assembly -ReadWrite -ReadSymbols
        # $switchedRefs = Switch-AssemblyNameReferences $moduleAssembly $ReferenceNameMatch $version
        $moduleReferences = $moduleAssembly.MainModule.AssemblyReferences
        $refs = $moduleReferences.ToArray() | Where-Object { $_.Name -match $ReferenceNameMatch } | ForEach-Object {
            if ($_.Version -ne $Version) {
                $moduleReferences.Remove($_) | Out-Null
                # $assembNameReference = (New-AssemblyReference $_ $version)
                $newMinor = "$($Version.Major).$($Version.Minor)"
                $newName = [Regex]::Replace($_.Name, "\.v\d{2}\.\d", ".v$newMinor")
                $regex = New-Object Regex("PublicKeyToken=([\w]*)") 
                $token = $regex.Match($AsemblyNameReference).Groups[1].Value
                $regex = New-Object Regex("Culture=([\w]*)")
                $culture = $regex.Match($_).Groups[1].Value
                $assembNameReference=[AssemblyNameReference]::Parse("$newName, Version=$($Version), Culture=$culture, PublicKeyToken=$token")
                $moduleReferences.Add($assembNameReference)
                @{
                    Old = $_.FullName
                    New = $assembNameReference
                }
            }
        }
        $switchedRefs=$refs | ConvertTo-Dictionary -KeyPropertyName Old -ValuePropertyName New
        if ($switchedRefs) {
            # Switch-TypeReferences $moduleAssembly $ReferenceNameMatch $switchedRefs
            $typeReferences = $moduleAssembly.MainModule.GetTypeReferences()
            $moduleAssembly.MainModule.Types | ForEach-Object {
                $typeReferences | Where-Object { $_.Scope -match $ReferenceNameMatch } | ForEach-Object { 
                    $scope = $switchedRefs[$_.Scope.FullName]
                    if ($scope) {
                        $_.Scope = $scope
                    }
                }
            }
            # Switch-Attributeparameters $moduleAssembly $ReferenceNameMatch $switchedRefs
            @(($moduleAssembly.MainModule.Types.CustomAttributes.ConstructorArguments | Where-Object {
                        $_.Type.FullName -eq "System.Type" -and $_.Value.Scope -match $ReferenceNameMatch
                    }).Value) | Where-Object { $_ } | ForEach-Object {
                $scope = $switchedRefs[$_.Scope.FullName]
                if ($scope) {
                    $_.Scope = $scope
                }
            }

            # Write-Assembly $modulePath $moduleAssembly $snkFile $Version
            $writeParams = New-Object WriterParameters
            $writeParams.WriteSymbols = $moduleAssembly.MainModule.hassymbols
            if ($SnkFile){
                $key = [System.IO.File]::ReadAllBytes($SnkFile.FullName)
                $writeParams.StrongNameKeyPair = [System.Reflection.StrongNameKeyPair]($key)
            }
            if ($writeParams.WriteSymbols) {
                $pdbPath = Get-Item $modulePath
                $pdbPath = "$($pdbPath.DirectoryName)\$($pdbPath.BaseName).pdb"
                $symbolSources = Get-SymbolSources $pdbPath
            }
            $moduleAssembly.Write($writeParams)
            if ($writeParams.WriteSymbols) {
                if ($symbolSources -notmatch "is not source indexed") {
                    Update-Symbols -pdb $pdbPath -SymbolSources $symbolSources
                }
                else {
                    $global:lastexitcode = 0
                    $symbolSources 
                }
            }
        }
        $moduleAssembly.Dispose();
    }
    end {
        
    }
}