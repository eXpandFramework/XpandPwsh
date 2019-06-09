param(
    $ApiKey
)

$file = "$PSScriptRoot\XpandPwsh\XpandPwsh.psd1"
$data = Get-Content $file -Raw
$onlineVersion = (Find-Module XpandPwsh -Repository PSGallery -ErrorAction Continue).Version.ToString()
$manifest = Invoke-Expression $data
if ($manifest.ModuleVersion -ne $onlineVersion) {
          
    Publish-Module -Path $PSScriptRoot\XpandPwsh -verbose -NugetApiKey $ApiKey -ErrorAction Stop    
}