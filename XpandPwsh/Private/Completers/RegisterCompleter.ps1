Push-Location $PSScriptRoot
@((. .\GetAzStorageContainer.ps1),(. .\GetAzStorageContainer.ps1))|ForEach-Object{
    $script=$_.Script
    $_.Parameters|ForEach-Object{
        Register-ArgumentCompleter -CommandName $_.CommandName -ParameterName $_.ParameterName -ScriptBlock $script
    }    
}
Pop-Location