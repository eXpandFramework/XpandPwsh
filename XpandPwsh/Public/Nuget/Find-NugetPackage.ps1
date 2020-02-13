function Find-NugetPackage {
    [CmdletBinding()]
    param (
        [ArgumentCompleter({
            [OutputType([System.Management.Automation.CompletionResult])]  # zero to many
            param(
                [string] $CommandName,
                [string] $ParameterName,
                [string] $WordToComplete,
                [System.Management.Automation.Language.CommandAst] $CommandAst,
                [System.Collections.IDictionary] $FakeBoundParameters
            )
            
            (Find-NugetPackage -Name $WordToComplete).Id
        })]
        [parameter(ValueFromPipeline,Mandatory)]
        [string]$Name,
        [switch]$AllVersions,
        [int]$Skip,
        [int]$Take,
        [switch]$Prelease,
        [switch]$OriginalFormat
    )
    
    begin {
        
    }
    
    process {
        $q = ConvertTo-HttpQueryString @{
            q = $name
            skip=$Skip
            take=$Take
            Prelease=$Prelease.IsPresent
        }
        (Invoke-RestMethod "https://azuresearch-usnc.nuget.org/query$q").data|ForEach-Object{
            if (!$OriginalFormat){
                [PSCustomObject]@{
                    Id = $_.id
                    Version=$_.Version
                }
            }
            else{
                $_
            }
        }
    }
    
    end {
        
    }
}