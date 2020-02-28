function Set-VsoVariable {
    [CmdletBinding()]
    [CmdLetTag(("#Azure","AzureDevOps"))]
    param (
        [parameter(ValueFromPipeline,Mandatory,Position=0)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
            @("build.updatebuildnumber")|where-object{$_ -like "$wordToComplete*"}
        })]
        [string]$Name,
        [parameter(Position=1)]
        $Value
    )
    
    begin {
    }
    
    process {
        $messgae="##vso[task.setvariable variable=$Name]$Value"
        if ($Name -eq "build.updatebuildnumber"){
            $messgae="##vso[$Name]$Value"
        }
        Write-Verbose -Verbose $messgae
    }
    
    end {
    }
}