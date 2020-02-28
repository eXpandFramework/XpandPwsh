function Get-PackageSourceLocations {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [string]$ProviderName,
        [ArgumentCompleter({
            [OutputType([System.Management.Automation.CompletionResult])]  # zero to many
            param(
                [string] $CommandName,
                [string] $ParameterName,
                [string] $WordToComplete,
                [System.Management.Automation.Language.CommandAst] $CommandAst,
                [System.Collections.IDictionary] $FakeBoundParameters
            )
            (Get-PackageSource |Where-Object{$_.Name -like "$wordtocomplete*"}).Name
        })]
        [string]$Name,
        [Switch]$AllTypes
    )
    
    begin {
        
    }
    
    process {
        $(Get-PackageSource|Where-object{
            (($providerName -and $_.ProviderName -eq $providerName) -or ($Name -and $_.Name -eq $Name))
        }|Select-Object -ExpandProperty Location -Unique|Where-Object{
            if (!$AllTypes){
                $_ -like "http*" -or (Test-Path $_)
            }
        })       
    }
    
    end {
        
    }
}