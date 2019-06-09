$GitHubUser
$ErrorActionPreference="Stop"

$lastmessage = (git log -1 --pretty=%B)|Select-Object -First 1

$v=((Get-Module XpandPwsh -ListAvailable).Version|Sort-Object -Descending |Select-Object -First 1)
$version="$($v.Major).$($v.Minor).$($v.Build)"
if ($version -eq $lastmessage){
    return
}
$wikiPath="C:\Work\eXpandFramework\XpandPwsh.wiki\"
$readMePath="$PSScriptRoot\..\ReadMe.md"
$readMeContent=Get-Content $readMePath -Raw
$cmdLetList = Get-Command * -Module XpandPwsh|Sort-Object Name

$regex = [regex] '(?is)# About(.*)## Installation'
$readMeContent = $regex.Replace($readMeContent, @"
# About
The module exports $($cmdLetList.Count) Cmdlets that can help you automate your every day tasks. The module is used in production from the eXpandFramework [build scripts](https://github.com/eXpandFramework/eXpand/blob/master/Support/Build/Build.ps1) and [Azure Tasks](https://github.com/eXpandFramework/Azure-Tasks).

In this page you can see a list of all Cmdlets with a short description. For details and real world examples search the [Wiki](https://github.com/eXpandFramework/XpandPwsh/wiki).
## Installation
"@
)

Set-Content $readMePath $readMeContent
$wikiUrl="https://github.com/$GitHubUser/XpandPwsh/wiki"

New-MarkdownHelp -Module XpandPwsh -OutputFolder "$PSSCriptRoot\..\..\XpandPwsh.wiki" -ErrorAction SilentlyContinue
Update-MarkdownHelp -Path "$PSSCriptRoot\..\..\XpandPwsh.wiki"
$cmdLetListTable=($cmdLetList|ForEach-Object{
    $cmdletName=$_.Name
    $cmdletPath="$wikiPath\$cmdletName.md"
    $mdFile=Get-Content $cmdletPath -Raw
    $regex = [regex] '(?is)## SYNOPSIS(.*)## SYNTAX'
    $mdFile = ($regex.Match($mdFile).Groups[1].Value).ToString().Trim();
    "|[$cmdletName]($wikiUrl/$cmdletName)|$mdFile|"
})|Out-String

$regex = [regex] '(?is)## Exported Functions-Cmdlets(.*)'
$readMeContent = $regex.Replace($readMeContent, @"
## Exported Functions-Cmdlets
To list the module command issue the next line into a PowerShell prompt.
``````ps1
Get-Command -Module XpandPwsh
``````
|Cmdlet|Synopsis|`r`n|---|---|
$cmdLetListTable 
"@
)

Set-Content $readMePath $readMeContent
if (git diff --name-only |Where-Object{$_ -like "*ReadMe.md"}){
    Copy-Item $readMePath "$wikiPath\Home.md"
    Write-Error "ReadMe changed" -ErrorAction Continue
    exit 1
}