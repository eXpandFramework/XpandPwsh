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
    New-Item "$PSScriptRoot\XpandPwsh\Cmdlets\bin" -ItemType Directory
    $publish=dotnet build "$PSScriptRoot\XpandPwsh\Cmdlets\src\XpandPwsh.CmdLets.sln"
    if ($LASTEXITCODE){
        throw   "Fail to publish $assemblyName`r`n`r`n$publish"
    }
    $publish         
    Publish-Module -Path $PSScriptRoot\XpandPwsh -verbose -NugetApiKey $ApiKey -ErrorAction Stop -SkipAutomaticTags
}