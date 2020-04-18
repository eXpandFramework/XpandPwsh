[PSCustomObject]@{
    Script = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
        (Get-AzStorageContainer -Context (Get-AzStorageAccount|Where-Object{$_.StorageAccountName -eq $env:AzStorageAccountName}).Context).Name
    }
    Parameters=@(
        [PSCustomObject]@{
            CommandName = (Get-Command "Clear-AzStorageBlob" -Module XpandPwsh).Name
            ParameterName = "Container"
        }
    )
}