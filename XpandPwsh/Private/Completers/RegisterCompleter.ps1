Push-Location $PSScriptRoot
Get-ChildItem *.ps1 -Exclude RegisterCompleter.ps1|ForEach-Object{
    $include= (. $_.FullName)
    $script=$include.Script
    $include.Parameters|ForEach-Object{
        Register-ArgumentCompleter -CommandName $_.CommandName -ParameterName $_.ParameterName -ScriptBlock $script
    }    
}
Pop-Location