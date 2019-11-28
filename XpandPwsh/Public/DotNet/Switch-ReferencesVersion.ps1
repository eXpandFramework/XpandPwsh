function Switch-ReferenceVersion() {
    param(
        [string]$modulePath, 
        [version]$Version,
        [string]$referenceFilter,
        [string]$snkFile,
        [System.IO.FileInfo[]]$assemblyList
    )
    if (!$assemblyList){
        $packagesFolder=Get-PackagesFolder
        $assemblyList=Get-ChildItem $packagesFolder -Include "*.dll","*.exe" -Recurse
    }
    $moduleAssemblyData = Get-MonoAssembly $modulePath $assemblyList -ReadSymbols
    $moduleAssembly = $moduleAssemblyData.assembly
    $moduleReferences = $moduleAssembly.MainModule.AssemblyReferences
    wh "References:" -Style Underline
    $moduleReferences.Fullname |Sort-Object
    $needsPatching = $false
    $moduleReferences.ToArray() | Where-Object { $_.Name -like $referenceFilter } | ForEach-Object {
        $dxReference = $_
        "Checking reference $_..."
        if ($dxReference.Version -ne $Version) {
            $moduleReferences.Remove($dxReference) | Out-Null
            $newMinor = "$($Version.Major).$($Version.Minor)"
            $newName = [Regex]::Replace($dxReference.Name, "\.v\d{2}\.\d", ".v$newMinor")
            $regex = New-Object Regex("PublicKeyToken=([\w]*)") 
            $token = $regex.Match($dxReference).Groups[1].Value
            $regex = New-Object Regex("Culture=([\w]*)")
            $culture = $regex.Match($dxReference).Groups[1].Value
            $newReference = [AssemblyNameReference]::Parse("$newName, Version=$($Version), Culture=$culture, PublicKeyToken=$token")
            $moduleReferences.Add($newreference)
            $moduleAssembly.MainModule.Types | ForEach-Object {
                $moduleAssembly.MainModule.GetTypeReferences() | Where-Object { $_.Scope -eq $dxReference } | ForEach-Object { 
                    $_.Scope = $newReference 
                }
            }
            wh "$($_.Name) version will changed from $($_.Version) to $($Version)`r`n" -ForegroundColor Blue
            $needsPatching = $true
        }
        else {
            wh "$($_.Name) Version ($($dxReference.Version)) matched nothing to do.`r`n" -ForegroundColor Blue
        }
    }
    if ($needsPatching) {
        wh "Patching $modulePath" -ForegroundColor Yellow
        $writeParams = New-Object WriterParameters
        $writeParams.WriteSymbols = $moduleAssembly.MainModule.hassymbols
        $key = [File]::ReadAllBytes($snkFile)
        $writeParams.StrongNameKeyPair = [System.Reflection.StrongNameKeyPair]($key)
        if ($writeParams.WriteSymbols) {
            $pdbPath = Get-Item $modulePath
            $pdbPath = "$($pdbPath.DirectoryName)\$($pdbPath.BaseName).pdb"
            $symbolSources = Get-SymbolSources $pdbPath
        }
        $moduleAssembly.Write($writeParams)
        wh "Patched $modulePath" -ForegroundColor Green
        if ($writeParams.WriteSymbols) {
            "Symbols $modulePath"
            if ($symbolSources -notmatch "is not source indexed") {
                Update-Symbols -pdb $pdbPath -SymbolSources $symbolSources
            }
            else {
                $symbolSources 
            }
        }
    }
    $moduleAssemblyData.Resolver.Dispose()
    $moduleAssembly.Dispose()
}