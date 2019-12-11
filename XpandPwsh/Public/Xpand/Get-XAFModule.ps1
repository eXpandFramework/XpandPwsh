function Get-XAFModule {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)]
        [string]$Path=".",
        [string[]]$Include=@("DevExpress.Express*.dll","Xpand.XAF.Modules.*.dll","Xpand.ExpressApp.*.dll")
    )
    
    begin {
        $Path=ConvertTo-Directory $Path
        Use-MonoCecil | Out-Null
        Use-NugetAssembly Xpand.Extensions.Mono.Cecil|Out-Null
    }
    
    process {
        Push-Location $Path
        $dxAssembly=Get-ChildItem "DevExpress.ExpressApp.v*.dll" -Recurse|Select-Object -First 1
        if (!$dxAssembly){
            throw "DevExpress.ExpressApp assembly not found in $Path"
        }
        Use-Object($a=Read-AssemblyDefinition $dxAssembly.FullName){
            $moduleBaseType=$a.MainModule.Types|Where-Object{$_.FullName -eq "DevExpress.ExpressApp.ModuleBase"}
            Get-ChildItem -include $Include -recurse|ForEach-Object{
                $assemblyPath=$_.FullName
                Use-Object($ma=Read-AssemblyDefinition $assemblyPath){
                    $ma.MainModule.Types|Where-Object{
                        [Xpand.Extensions.Cecil.MonoCecilExtensions]::BaseClasses($_)|Where-Object{$_.FullName -eq $moduleBaseType.FullName}
                    }|Where-Object{
                        !$_.IsAbstract -and $_.FullName -ne $moduleBaseType.FullName
                    }|ForEach-Object{
                        [PSCustomObject]@{
                            Name = $_.Name
                            FullName=$_.FullName
                            Assembly=$assemblyPath
                        }
                    }
                }
            }
        }
        Pop-Location
    }
    
    end {
        
    }
}