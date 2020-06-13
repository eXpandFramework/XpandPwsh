[PSCustomObject]@{
    Script = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
        (Get-ReferenceConflict).Key|Where-Object{$_ -like "$wordToComplete*"}
    }
    Parameters=@(
        [PSCustomObject]@{
            CommandName = "Get-ReferenceConflict"
            ParameterName = "Filter"
        }
    )
}