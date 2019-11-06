
function Get-PaketReferences {
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
                $regex = [regex] 'nuget ([^ ]*) ([^ ]*)'
                $result = $regex.Match($_);
                [PSCustomObject]@{
                    Include    = $result.Groups[1].Value
                    Version = $result.Groups[2].Value
                }
            }
            $c=Get-Content $paketReferencesFile|ForEach-Object{
                $ref=$_
                $d=$dependencies|Where-Object{
                    $ref-eq $_.Include
                }
                $d
            }
            Write-Output $c
        }
    }
    
    end {
        
    }
}