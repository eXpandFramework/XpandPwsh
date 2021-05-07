param(
    $ApiKey
)

$file = "$PSScriptRoot\XpandPwsh\XpandPwsh.psd1"
$data = Get-Content $file -Raw
$onlineVersion = (Find-Module XpandPwsh -Repository PSGallery -ErrorAction Continue).Version.ToString()
$manifest = Invoke-Expression $data
"manifest.ModuleVersion=$($manifest.ModuleVersion)"
"onlineVersion=$onlineVersion"
if ($manifest.ModuleVersion -ne $onlineVersion) {
    $binFolder="$PSScriptRoot\XpandPwsh\Cmdlets\bin"
    if (!(Test-Path $binFolder)){
        New-Item $binFolder -ItemType Directory
    }
    
    $publish=dotnet build "$PSScriptRoot\XpandPwsh\Cmdlets\src\XpandPwsh.CmdLets.sln" --source https://api.nuget.org/v3/index.json
    if ($LASTEXITCODE){
        throw   "Fail to publish $assemblyName`r`n`r`n$publish"
    }
    $publish         
    $ErrorActionPreference="Stop"
    
    Import-Module $PSScriptRoot\XpandPwsh\XpandPwsh.psm1 -Verbose
    $m=Get-Module XpandPwsh
    Publish-Module -Path (Get-Item $m.Path).DirectoryName -verbose -NugetApiKey $ApiKey -SkipAutomaticTags -Repository PSGallery
}