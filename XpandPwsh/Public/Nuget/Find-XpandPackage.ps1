function Find-XpandPackage {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [ArgumentCompleter({
            [OutputType([System.Management.Automation.CompletionResult])]  # zero to many
            param(
                [string] $CommandName,
                [string] $ParameterName,
                [string] $WordToComplete,
                [System.Management.Automation.Language.CommandAst] $CommandAst,
                [System.Collections.IDictionary] $FakeBoundParameters
            )
            
            (find-xpandpackage "*$WordToComplete*" ).id
        })]
        [string]$Filter,
        [parameter(Position = 1)]
        [ValidateSet("All", "Release", "Lab")]
        [string]$PackageSource = "Release"
    )
    
    begin {
    }
    
    process {
        
        if ($PackageSource -ne "all") {
            $packages=Get-XpandPackages -Source $PackageSource 
            $p=$packages| Where-Object { 
                $_.Id -like $Filter 
            }
        }
        else{
            $p = $(Find-XpandPackage -Filter $Filter -PackageSource Lab) , $(Find-XpandPackage -Filter $Filter -PackageSource Release)
        }
        $p 
    }
    
    end {
    }
}