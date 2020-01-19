function Get-NugetPackageDependencies {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string]$Id,
        [string]$Version,
        [switch]$AllVersions,
        [ArgumentCompleter({
            [OutputType([System.Management.Automation.CompletionResult])]  # zero to many
            param(
                [string] $CommandName,
                [string] $ParameterName,
                [string] $WordToComplete,
                [System.Management.Automation.Language.CommandAst] $CommandAst,
                [System.Collections.IDictionary] $FakeBoundParameters
            )
            
            (Get-packageSource).Name|where-object{$_ -like "$wordToComplete*"}
        })]
        [string]$Source=(get-feed -Nuget)
    )
    
    begin {
        if ($source -in (Get-packageSource).Name ){
            $Source=Get-PackageSourceLocations -Name $Source
        }
    }
    
    process {
        $a=@{
            Name=$Id
            Source=$Source
            AllVersions=$AllVersions
        }
        if ($Version){
            $a.Add("Version",$Version)
        }
        elseif ($AllVersion){
            $a.Add("AllVersions",$AllVersions)
        }
        (Get-NugetPackageSearchMetadata @a).DependencySets.Packages
    }
    
    end {
        
    }
}