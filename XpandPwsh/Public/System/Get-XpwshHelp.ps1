function Get-XpwshHelp {
    [CmdletBinding()]
    [Alias("gxh")]
    [CmdLetTag()]
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
            
            Get-XPwshCommand|Where-Object{$_.Name -like "*$WordToComplete*"}
        })]
        [parameter(Mandatory,ValueFromPipelineByPropertyName,ValueFromPipeline)]
        [string]$Command
    )
    
    begin {
        
    }
    
    process {
        if (Get-XPwshCommand $Command ){
            Start-Process "https://github.com/eXpandFramework/XpandPwsh/wiki/$Command"
        }
        else{
            throw "$Command not found in XpandPwsh module."
        }
    }
    
    end {
        
    }
}