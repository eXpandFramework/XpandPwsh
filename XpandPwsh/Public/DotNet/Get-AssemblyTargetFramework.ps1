function Get-AssemblyTargetFramework {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#monocecil"))]
    param (
        [parameter(ValueFromPipeline,Mandatory,ParameterSetName="File",Position=0)]
        [System.IO.FileInfo]$Assembly
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        Use-Object($a=Read-AssemblyDefinition $Assembly){
            $attribute=($a.CustomAttributes|Where-Object{$_.AttributeType.FullName -eq "System.Runtime.Versioning.TargetFrameworkAttribute"})
            ($attribute.ConstructorArguments|Select-Object -First 1).Value
        }
    }
    end {
        
    }
}