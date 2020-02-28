function Get-AssemblyReference {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#monocecil"))]
    param (
        [parameter(ValueFromPipeline, Mandatory)]
        [string]$AssemblyPath,
        [string]$NameFilter,
        [string]$VersionFilter,
        [System.IO.FileInfo[]]$AssemblyList = (Get-ChildItem $AssemblyPath *.dll),
        [Switch]$Recurse
    )
    
    begin {
        Use-MonoCecil | Out-Null
    }
    
    process {
        [Mono.Cecil.AssemblyDefinition]$assembly = Read-AssemblyDefinition $AssemblyPath $AssemblyList
        $refs = $assembly.MainModule.AssemblyReferences | ForEach-Object {
            [PSCustomObject]@{
                Name     = $_.Name
                Version  = $_.Version.ToString()
                FullName = $_.FullName
            }
        } | Where-Object {
            $nameMatch = !$NameFilter -or $_.Name -like $NameFilter
            $versionMatch = !$VersionFilter -or $_.Version -like $VersionFilter 
            $nameMatch -and $versionMatch

        }
        $allRefs = @($refs)
        $assemblyChecked = @($AssemblyPath)
        if ($Recurse) {
            while ($refs) {
                $refs = @($refs | ForEach-Object {
                    $refPath="$([System.IO.Path]::GetDirectoryName($AssemblyPath))\$($_.Name).dll"
                    if ($refPath -notin $assemblyChecked) {
                        $a = @{
                            AssemblyPath  = $refPath
                            NameFilter    = $NameFilter 
                            VersionFilter = $VersionFilter
                            Recurse       = $Recurse
                        }
                        Get-AssemblyReference  @a
                        $assemblyChecked += $refPath
                    }
                })
                $allRefs += @($refs)
            }
        }
        
        $allRefs | Sort-Object Name -Unique
        $assembly.dispose()
    }
    
    end {
        
    }
}