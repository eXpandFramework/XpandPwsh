$GitHubUser="apobekiaris"
if (!(Get-Module XpandPwsh -ListAvailable)) {
    Install-Module XpandPwsh
}



$v=((Get-Module XpandPwsh -ListAvailable).Version|Sort-Object -Descending |Select-Object -First 1)
$version="$($v.Major).$($v.Minor).$($v.Build)"
if ($version -eq $lastmessage){
    return
}


$lastSha = Get-GitLastSha "https://github.com/$GitHubUser/XpandPwsh.git"

$lastSha
$diffs=git diff --name-only "$lastSha" HEAD 
$diffs
$needNewVersion = ($diffs| Where-Object { $_ -notlike ".githooks*" } | Select-Object -First 1) | Where-Object { $_ -like "XpandPwsh/*" -and $_ -notlike "*.md" -and $_ -notlike "*.yml" }
"needNewVersion=$needNewVersion"
if ($needNewVersion) {
    $file = "$PSScriptRoot\..\XpandPwsh\XpandPwsh.psd1"
    $data = Get-Content $file -Raw
    $manifest = Invoke-Expression $data
    $moduleVersion = New-Object System.Version($manifest.ModuleVersion)
    "moduleVersion=$moduleVersion"
    $c = New-Object System.Net.WebClient
    $readme = $c.DownloadString("https://raw.githubusercontent.com/$GitHubUser/XpandPwsh/master/ReadMe.md")
    $needNewMinor = (Get-Command -Module XpandPwsh) | Where-Object { $readme -notmatch $_.Name } | Select-Object -First 1
    "needNewMinor=$needNewMinor"
    if ($needNewMinor) {
        $newMinor = $moduleVersion.Minor + 1
        $newBuild = 0
    }
    else {
        $onlineVersion = New-Object System.Version ((Find-Module XpandPwsh -Repository PSGallery).Version)
        "onlineVersion=$onlineVersion"
        $newMinor = 0
        $newBuild = 0
        if ($moduleVersion.Major -eq $onlineVersion.Major) {
            $newMinor = $onlineVersion.Minor
            $newBuild = $onlineVersion.Build + 1
        }
    }
    
    $newVersion = "$($moduleVersion.Major).$newMinor.$newBuild"
    "newVersion=$newVersion"
    if ($manifest.ModuleVersion -ne $newVersion) {
        Set-Content $file $data.Replace($manifest.ModuleVersion, $newVersion)
        & git commit -a -m $newVersion
        & git tag $newVersion
        Write-Error "Version Changed" -ErrorAction Continue
        exit 1
    }
}

