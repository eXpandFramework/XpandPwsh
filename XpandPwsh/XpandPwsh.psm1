using namespace System.Net
$psCoreCmdlets=@("Format-Text.ps1")
$exclude=@("Install-Module.ps1")
. $PSScriptRoot\private\attributes.ps1
Get-ChildItem -Path $PSScriptRoot\public\*.ps1 -Exclude ($exclude+$psCoreCmdlets) -Recurse  |ForEach-Object {. $_.FullName}
if ($PSVersionTable.Psedition -eq "Core"){
    Get-ChildItem -Path $PSScriptRoot\public -Include $psCoreCmdlets -Exclude $exclude -Recurse  |ForEach-Object {. $_.FullName}
}
$global:XpandPwshPath=$PSScriptRoot
. $PSScriptRoot\private\Completers\RegisterCompleter.ps1
$global:PathToScript = Switch ($Host.name){
    'Visual Studio Code Host' { split-path $psEditor.GetEditorContext().CurrentFile.Path }
    'Windows PowerShell ISE Host' {  Split-Path -Path $psISE.CurrentFile.FullPath }
    'ConsoleHost' { $PSScriptRoot }
}

