if (!(Get-Module XpandPosh -ListAvailable)) {
    Install-Module XpandPosh
}
Import-Module XpandPosh -Force
$lastmessage = git log -1 --pretty=%B
if ($lastmessage -eq (Get-Module XpandPosh -ListAvailable).Version) {
    return
}
$lastSha = Get-GitLastSha "https://github.com/eXpandFramework/XpandPosh.git"
$lastSha
$needNewVersion = (git diff --name-only "$lastSha" HEAD | Where-Object { $_ -notlike ".githooks*" } | Select-Object -First 1) | Where-Object { $_ -like "XpandPosh/*" -and $_ -notlike "*.md" -and $_ -notlike "*.yml" }
"needNewVersion=$needNewVersion"
if ($needNewVersion) {
    $file = "$PSScriptRoot\..\XpandPosh\XpandPosh.psd1"
    $data = Get-Content $file -Raw
    $manifest = Invoke-Expression $data
    $moduleVersion = New-Object System.Version($manifest.ModuleVersion)
    "moduleVersion=$moduleVersion"
    $c = New-Object System.Net.WebClient
    $readme = $c.DownloadString("https://raw.githubusercontent.com/eXpandFramework/XpandPosh/master/ReadMe.md")
    $needNewMinor = (Get-Command -Module XpandPosh) | Where-Object { $readme -notmatch $_.Name } | Select-Object -First 1
    "needNewMinor=$needNewMinor"
    if ($needNewMinor) {
        $newMinor = $moduleVersion.Minor + 1
        $newBuild = 0
    }
    else {
        $onlineVersion = New-Object System.Version ((Find-Module XpandPosh -Repository PSGallery).Version)
        $newMinor = 0
        $newBuild = 0
        if ($moduleVersion.Major -eq $onlineVersion.Major) {
            $newMinor = $onlineVersion.Minor
            $newBuild = $onlineVersion.Build + 1
        }
    }
    
    $newVersion = "$($moduleVersion.Major).$newMinor.$newBuild"
    if ($manifest.ModuleVersion -ne $newVersion) {
        Set-Content $file $data.Replace($manifest.ModuleVersion, $newVersion)
        & git commit -a -m $newVersion
        & git tag $newVersion
        Write-Error "Version Changed" -ErrorAction Continue
        exit 1
    }
}

