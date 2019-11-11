
function Invoke-PaketRestore {
    [CmdletBinding()]
    param (
        [switch]$Force,
        [string]$Group,
        [string]$Path="." ,
        [switch]$WarnOnChecks 
    )
    
    begin {
        
    }
    
    process {
        [System.IO.Path]::GetFullPath(".")
        $paketExe=(Get-PaketDependenciesPath $path)
        if ($paketExe){
            $xtraArgs = @();
            if ($Force) {
                $xtraArgs += "--force"
            }
            if ($Group) {
                $xtraArgs += "--group $group"
            }
            if (!$WarnOnChecks) {
                $xtraArgs += "--fail-on-checks"
            }
            if ($Force){
                $root=(Get-Item $paketExe).Directory.Parent.FullName
                Remove-Item "$root\paket-files\paket.restore.cached" -ErrorAction SilentlyContinue
            }
            Set-Location (Get-Item $paketExe).DirectoryName
            dotnet paket restore @xtraArgs
        }
    }
    
    end {
        
    }
}