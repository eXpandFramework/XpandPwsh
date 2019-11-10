
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
        $paketExe=(Get-PaketPath $path)
        if ($paketExe){
            $xtraArgs = @();
            if ($Force) {
                $xtraArgs += "--Force"
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
            & $paketExe restore @xtraArgs
        }
    }
    
    end {
        
    }
}