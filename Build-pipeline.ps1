param(
    $ApiKey
)
$file = "$PSScriptRoot\XpandPwsh\XpandPwsh.psd1"
$data = Get-Content $file -Raw
$manifest = Invoke-Expression $data
$onlineVersion = (Find-Module XpandPwsh -Repository PSGallery -ErrorAction Continue).Version.ToString()
if ($manifest.ModuleVersion -ne $onlineVersion) {
          
    Publish-Module -Path $PSScriptRoot\XpandPwsh -verbose -NugetApiKey $ApiKey -ErrorAction Stop    
}