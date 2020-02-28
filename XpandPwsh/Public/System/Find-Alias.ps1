function Find-Alias {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory)]
        [ArgumentCompleter({
            [OutputType([System.Management.Automation.CompletionResult])]  # zero to many
            param(
                [string] $CommandName,
                [string] $ParameterName,
                [string] $WordToComplete,
                [System.Management.Automation.Language.CommandAst] $CommandAst,
                [System.Collections.IDictionary] $FakeBoundParameters
            )
            
            Get-Command|where-object{$_.Name -like "$WordToComplete*"}
        })]
        [string]$Name
    )
    
    begin {
        
    }
    
    process {
        get-alias |where-object {$_.Definition -eq $Name}
    }
    
    end {
        
    }
}