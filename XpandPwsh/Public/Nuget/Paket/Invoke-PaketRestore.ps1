
function Invoke-PaketRestore {
    [CmdletBinding()]
    param (
        [switch]$UseCache,
        [string]$Group,
        [switch]$WarnOnChecks ,
        [switch]$Strict, 
        [switch]$Install 
    )
    
    begin {
        
    }
    
    process {
        $a=@{
            Strict=$Strict
        }
        Get-PaketDependenciesPath @a |ForEach-Object{
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
            if (!$UseCache){
                $root=$_.DirectoryName
                Remove-Item "$root\paket-files\paket.restore.cached" -ErrorAction SilentlyContinue
            }
            Write-Host "Paket Restore $($_.Fullname)" -f Blue
            try {
                Invoke-Script{dotnet paket restore @xtraArgs}
            }
            catch {
                if ($Install){
                    Invoke-Script{dotnet paket install}
                }
                else{
                    throw $_
                }
            }
        }
    }
    
    end {
        
    }
}