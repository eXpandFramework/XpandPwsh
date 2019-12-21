function Get-XAFModule {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)]
        [string]$Path = ".",
        [System.IO.FileInfo[]]$AssemblyList=@(),
        [string[]]$Include = @("DevExpress.Express*.dll", "Xpand.XAF.Modules*.dll", "Xpand.ExpressApp*.dll"),
        [string[]]$Exclude=@("*Tests*")
    )
    
    begin {
        $Path = ConvertTo-Directory $Path
        Use-MonoCecil | Out-Null
        Use-NugetAssembly Xpand.Extensions.Mono.Cecil | Out-Null
        $Include=$Include|ForEach-Object{
            if ($_ -notlike "*.dll"){
                "$_.dll"
            }
            else{
                $_
            }
        }
    }
    
    process {
        
        Push-Location $Path
        $assemblies=Get-ChildItem -include $Include -Exclude $Exclude -recurse -file|Sort-Object BaseName -Unique
        $assemblies.Name|Write-Verbose 
        $assemblies| Invoke-Parallel -variablesToimport "AssemblyList" -Script {
            $moduleBaseType = "DevExpress.ExpressApp.ModuleBase"
            $assemblyPath = $_.FullName
            Use-Object($ma = Read-AssemblyDefinition $assemblyPath $AssemblyList) {
                $ma.MainModule.Types | Where-Object {
                    [Xpand.Extensions.Cecil.MonoCecilExtensions]::BaseClasses($_) | Where-Object { $_.FullName -eq $moduleBaseType }
                } | Where-Object {
                    !$_.IsAbstract -and $_.FullName -ne $moduleBaseType
                } | ForEach-Object {
                    [PSCustomObject]@{
                        Name     = $_.Name
                        FullName = $_.FullName
                        Assembly = $assemblyPath
                    }
                }
            }
        }|Where-Object{$_}|sort-object FullName
        Pop-Location
    }
    
    end {
        
    }
}