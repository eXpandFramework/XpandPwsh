function Get-PSCmdletText {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [string]$Name,
        [System.IO.FileInfo]$ScriptFile
    )
    
    begin {
        $PSCmdlet | Write-PSCmdLetBegin
        $fps1 = "$env:TEMP\$([guid]::NewGuid()).ps1"
        $tokens = $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($ScriptFile,[ref]$tokens,[ref]$errors)
        $functions=@()
    }
    
    process {
        $functions+=$Name
    }
    
    end {
        $functionDefinitions = $ast.FindAll( {
            param([System.Management.Automation.Language.Ast] $Ast)
            $Ast -is [System.Management.Automation.Language.FunctionDefinitionAst] -and
            # Class methods have a FunctionDefinitionAst under them as well, but we don't want them.
            ($PSVersionTable.PSVersion.Major -lt 5 -or
                $Ast.Parent -isnot [System.Management.Automation.Language.FunctionMemberAst]) -and
                $Ast.name -in $functions

        }, $true)
        Set-Content $fps1 $functionDefinitions.Extent.Text
        Write-Verbose $fps1
        Get-Item $fps1
    }
}