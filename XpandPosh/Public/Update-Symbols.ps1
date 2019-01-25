function Update-Symbols {
    param(
        [parameter(Mandatory)]
        [string]$symbolsFolder,
        [parameter(Mandatory)]
        [string]$user,
        [parameter(Mandatory)]
        [string]$repository,
        [parameter(Mandatory)]
        [string]$branch,
        [parameter(Mandatory)]
        [string]$sourcesRoot,
        [parameter(Mandatory)]
        [string]$dbgToolsPath
    )
    & "$PSScriptRoot\Sourcepack.ps1" -symbolsfolder $symbolsFolder -userId $user -repository $repository -branch $branch -sourcesRoot $sourcesRoot  -githuburl https://raw.githubusercontent.com -serverIsRaw -dbgToolsPath $dbgToolsPath  
}