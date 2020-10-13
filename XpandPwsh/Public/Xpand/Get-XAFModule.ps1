function Get-XAFModule {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(ValueFromPipeline, ParameterSetName = "path")]
        [string]$Path = ".",
        [parameter(ValueFromPipeline, ParameterSetName = "assemblies")]
        [System.IO.FileInfo[]]$Assemblies ,
        [System.IO.FileInfo[]]$AssemblyList = (Get-ChildItem $Path *.dll),
        [string[]]$Include = @("DevExpress.Express*.dll", "Xpand.XAF.Modules*.dll", "Xpand.ExpressApp*.dll"),
        [string[]]$Exclude = @("*Tests*")
    )
    
    begin {
        
        $Path = ConvertTo-Directory $Path
        Use-MonoCecil | Out-Null
        Use-NugetAssembly Xpand.Extensions.Mono.Cecil | Out-Null
        $Include = $Include | ForEach-Object {
            if ($_ -notlike "*.dll") {
                "$_.dll"
            }
            else {
                $_
            }
        }
    }
    
    process {
        
        if ($PSCmdlet.ParameterSetName -eq "path") {
            Push-Location $Path
            $assemblies = Get-ChildItem -include $Include -Exclude $Exclude -recurse -file | Sort-Object BaseName -Unique
            if ($assemblies.Name) {
                $assemblies.Name | Write-Verbose 
            }
        }
        
        $assemblies | ForEach-Object {
            $moduleBaseType = "DevExpress.ExpressApp.ModuleBase"
            $assemblyPath = $_.FullName
            Write-Verbose "Reading assembly $assemblyPath"
            Use-Object($ma = Read-AssemblyDefinition $assemblyPath $AssemblyList) {
                if ($ma.MainModule.AssemblyReferences.Name -like "DevExpress*") {
                    $ma.MainModule.Types | Where-Object {
                        [Xpand.Extensions.Mono.Cecil.MonoCecilExtensions]::BaseClasses($_) | Where-Object { $_.FullName -eq $moduleBaseType }
                    } | Where-Object {
                        !$_.IsAbstract -and $_.FullName -ne $moduleBaseType
                    } | ForEach-Object {
                        [PSCustomObject]@{
                            Name     = $_.Name
                            FullName = $_.FullName
                            Assembly = $assemblyPath
                            Platform = (Get-AssemblyMetadata $assemblyPath -key platform).value
                        }
                    }
                }
            }
        } | Where-Object { $_ } | Sort-Object FullName
        Pop-Location
    }
    
    end {
        
    }
}