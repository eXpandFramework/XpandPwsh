
function Get-PaketPackageReference {
    [CmdletBinding()]
    param (
        [string]$Path = "."
    )
    
    begin {
        
    }
    
    process {
        $paketDirectoryInfo = Get-Item $Path
        $paketReferencesFile = "$($paketDirectoryInfo.FullName)\paket.references"
        if (Test-Path $paketReferencesFile) {
            $paketDependeciesFile = "$((Get-PaketPath $path).DirectoryName)\..\paket.dependencies"
            $dependencies = Get-Content $paketDependeciesFile | ForEach-Object {
                $parts=$_.Trim().Split(' ')
                if ($parts[0] -eq "nuget"){
                    if ($parts.Length -gt 2){
                        $version=$parts[2]
                    }
                    [PSCustomObject]@{
                        Include    = $parts[1]
                        Id    = $parts[1]
                        Version = $version
                    }
                }
                
            }|Where-Object{$_.Id}
            $c=Get-Content $paketReferencesFile|ForEach-Object{
                $ref=$_
                $d=$dependencies|Where-Object{
                    $ref -eq $_.Include
                }
                $d
            }
            Write-Output $c
        }
    }
    
    end {
        
    }
}