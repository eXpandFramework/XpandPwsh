
function Invoke-PaketShowInstalled {
    [CmdletBinding()]
    param (
        [parameter(ParameterSetName = "Project")]
        [string]$Project,
        [switch]$OnlyDirect,
        [switch]$PrivateAssets
    )
    
    begin {
                
    }
    
    process {
        (Get-PaketDependenciesPath -strict) | ForEach-Object {
            $depsFile = $_
            Write-Host "DependencyFile: $($depsFile.FullName)" -f Blue
            $xtraArgs = @( );
            if (!$OnlyDirect) {
                $xtraArgs += "--all"
            }
            Push-Location (Get-Item $_).DirectoryName
            $pakets = Invoke-Script {
                $lockFile="$($depsFile.DirectoryName)\paket.lock"
                if (Test-Path $lockFile) {
                    if ($Project) {
                        Invoke-Script { dotnet paket show-installed-packages --project $Project --silent @xtraArgs }
                    }
                    else {
                        Invoke-Script { dotnet paket show-installed-packages @xtraArgs }
                    }
                }
                else{
                    throw "Missing lock, please use paket-install ($lockFile)" 
                }
            }
            
            $paketFile = (Get-PaketFiles -Strict).DepsFile
            $pakets | ForEach-Object {
                $parts = $_.split(" ")
                
                [PSCustomObject]@{
                    Group   = $parts[0]
                    Id      = $parts[1]
                    Version = $parts[3]
                }
            } | ForEach-Object {
                $req = $paketFile | Get-PaketPackageRequirement -filter $_.Id
                [PSCustomObject]@{
                    Id           = $_.id
                    Version      = $_.Version
                    Group        = $_.Group
                    PrivateAsset = $req.Settings -eq "copy_local: false"
                    Requirement  = $req
                }
            } | Where-Object {
                $PrivateAssets -or !$_.PrivateAsset
            }
            Pop-Location
        }
        
    }
    
    end {
        
    }
}

function Invoke-PaketCommand {
    param(
        [Parameter(Mandatory)]
        [scriptblock]$Script
    )
    & $Script
    Approve-LastExitCode
}