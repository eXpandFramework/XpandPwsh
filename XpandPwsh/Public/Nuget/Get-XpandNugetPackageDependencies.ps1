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
        [string]$Id,
        [string]$Version,
        [switch]$AllVersions,
        [ArgumentCompleter( {
                [OutputType([System.Management.Automation.CompletionResult])]  # zero to many
                param(
                    [string] $CommandName,
                    [string] $ParameterName,
                    [string] $WordToComplete,
                    [System.Management.Automation.Language.CommandAst] $CommandAst,
                    [System.Collections.IDictionary] $FakeBoundParameters
                )
            
                (Get-PackageSource).Name | Where-Object { $_ -like "$wordToComplete*" }
            })]
        [string]$Source = (Get-PackageFeed -Nuget)        
    )
    
    begin {
        
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