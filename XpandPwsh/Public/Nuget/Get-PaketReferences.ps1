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
            $paketDirectoryInfo = $paketDirectoryInfo.Parent
            $paketDependeciesFile = "$($paketDirectoryInfo.FullName)\paket.dependecies"
            while (!(Test-Path $paketDependeciesFile)) {
                $paketDirectoryInfo = $paketDirectoryInfo.Parent
                $paketDependeciesFile = "$($paketDirectoryInfo.FullName)\paket.dependecies"
            }
            $dependencies = Get-Content $paketDependeciesFile | ForEach-Object {
                $regex = [regex] 'nuget ([^ ]*) ([^ ]*)'
                $result = $regex.Match($_);
                [PSCustomObject]@{
                    Include    = $result.Groups[1].Value
                    Version = $result.Groups[2].Value
                }
            }
            Get-Content $paketReferencesFile|ForEach-Object{
                $dependencies|Where-Object{$_.Name -eq $_}
            }
        }
    }
    
    end {
        
    }
}