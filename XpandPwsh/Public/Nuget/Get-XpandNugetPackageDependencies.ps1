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
        [parameter()][string]$Version,
        [parameter()][switch]$AllVersions,
        [validateset("Release","Lab")]
        [parameter()][string[]]$Source
    )
    
    begin {
    }
    
    process {
        $a = @{
            Id         = $id 
            Version    = $Version 
            Source     = ($source|ForEach-Object{Get-PackageFeed -FeedName $_})
            AllVersion = $AllVersions
            FilterRegex = "Xpand"
            Recurse=$true
        }
        Get-NugetPackageDependencies @a 
    }
    
    end {
        
    }
}