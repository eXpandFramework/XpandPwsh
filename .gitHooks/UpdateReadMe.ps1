$ErrorActionPreference="Stop"
$wikiPath="C:\Work\eXpandFramework\XpandPosh.wiki\"
$readMePath="$PSScriptRoot\..\ReadMe.md"
$readMeContent=Get-Content $readMePath -Raw
$cmdLetList = Get-Command * -Module XpandPosh|Sort-Object Name

$regex = [regex] '(?is)# About(.*)## Installation'
$readMeContent = $regex.Replace($readMeContent, @"
# About
The module exports $($cmdLetList.Count) Cmdlets that can help you automate your every day tasks. The module is used in production from the eXpandFramework [build scripts](https://github.com/eXpandFramework/eXpand/blob/master/Support/Build/Build.ps1) and [Azure Tasks](https://github.com/eXpandFramework/Azure-Tasks).

In this page you can see a list of all Cmdlets with a short description. For details and real world examples search the [Wiki](https://github.com/eXpandFramework/XpandPosh/wiki).
## Installation
"@
)

Set-Content $readMePath $readMeContent
$wikiUrl="https://github.com/eXpandFramework/XpandPosh/wiki"

$cmdLetListTable=($cmdLetList|ForEach-Object{
    $cmdletName=$_.Name
    $mdFile=Get-Content "$wikiPath\$cmdletName.md" -Raw
    $regex = [regex] '(?is)## SYNOPSIS(.*)## SYNTAX'
    $mdFile = ($regex.Match($mdFile).Groups[1].Value).ToString().Trim();
    "|[$cmdletName]($wikiUrl/$cmdletName)|$mdFile|"
})|Out-String

$regex = [regex] '(?is)## Exported Functions-Cmdlets(.*)'
$readMeContent = $regex.Replace($readMeContent, @"
## Exported Functions-Cmdlets
To list the module command issue the next line into a PowerShell prompt.
``````ps1
Get-Command -Module XpandPosh
``````
|Cmdlet|Synopsis|`r`n|---|---|
$cmdLetListTable 
"@
)

Set-Content $readMePath $readMeContent
if (git diff --name-only |Where-Object{$_ -like "*ReadMe.md"}){
    Write-Error "ReadMe changed" -ErrorAction Continue
    exit 1
}