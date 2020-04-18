function Get-XpandNugetPackageDependencies {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [ArgumentCompleter( {
                [OutputType([System.Management.Automation.CompletionResult])]  # zero to many
                param(
                    [string] $CommandName,
                    [string] $ParameterName,
                    [string] $WordToComplete,
                    [System.Management.Automation.Language.CommandAst] $CommandAst,
                    [System.Collections.IDictionary] $FakeBoundParameters
                )
            
                (Find-XpandPackage "*$WordToComplete*" ).id
            })]
        [parameter()][string]$Id,
        [parameter()][string]$Version,
        [parameter()][switch]$AllVersions,
        [parameter()][string]$Source = (Get-PackageSource).Name
    )
    
    begin {
        $Source=ConvertTo-PackageSourceLocation $Source
    }
    
    process {
        $a = @{
            Id         = $id 
            Version    = $Version 
            Source     = $Source
            AllVersion = $AllVersions
            FilterRegex = "Xpand"
            Recurse=$true
        }
        Get-NugetPackageDependencies @a 
    }
    
    end {
        
    }
}