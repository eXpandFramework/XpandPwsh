
function Get-GitFile {
    [CmdletBinding()]
    [CmdLetTag("#git")]
    param(
        [parameter(Mandatory)]
        [string]$Url,
        [string[]]$Path,
        [string]$Filter,
        [switch]$Recurse,
        [switch]$Force

    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        Push-Location $env:TEMP
        $repoName=$Url.Substring(0,$Url.Length-4)
        $repoName=$repoName.Substring($repoName.LastIndexOf("/")+1)
        if ($Force -and (Test-Path ".\$repoName") -and !(Test-GitRepoIsValid ".\$repoName")){
            Remove-Item ".\$repoName" -Force -Recurse
        }
        if (!(Test-Path ".\$repoName") -or (Get-GitLastSha $Url) -ne (Get-GitLastSha ".\$repoName")){
            if (Test-Path ".\$repoName"){
                Remove-Item .\$repoName -Force -Recurse
            }
            Invoke-Script{git clone $Url}
        }
        Push-Location ".\$repoName"
        Get-ChildItem $Path $Filter -Recurse:$Recurse -file
        Pop-Location
        Pop-Location
    }
    
    end {
        
    }
}