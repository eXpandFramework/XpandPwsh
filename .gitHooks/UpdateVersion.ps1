$onlineVersion=New-Object System.Version ((Find-Module XpandPosh -Repository PSGallery).Version)
$file="$PSScriptRoot\..\XpandPosh\XpandPosh.psd1"
$data=Get-Content $file -Raw
$manifest=Invoke-Expression $data
$newBuild =$onlineVersion.Build +1
$newVersion="$($onlineVersion.Major).$($onlineVersion.Minor).$($newBuild)"
if ($manifest.ModuleVersion -ne $newVersion){
    Set-Content $file $data.Replace($manifest.ModuleVersion,$newVersion)
    & git commit -a -m $newVersion
    & git tag $newVersion
    Write-Error "Version Changed" -ErrorAction Continue
    exit 1
}

