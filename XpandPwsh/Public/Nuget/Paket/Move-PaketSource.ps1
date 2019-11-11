
function Move-PaketSource {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [int]$Index,
        [parameter(Mandatory)]
        [string]$Target,
        [string]$Path = "."
    )
    
    begin {
        
    }
    
    process {
        $paketExe=(Get-PaketDependenciesPath $path)
        if ($paketExe){
            $depsDir=(Get-item $paketExe).Directory.Parent.FullName
            $i=0;
            $deps=(Get-Content $depsDir\paket.dependencies|ForEach-Object{
                if ($_ -like "source *"){
                    if ($Index -eq $i){
                        "source $Target"
                        $lock=Get-Content $depsDir\paket.lock
                        $lock=$lock.Replace($_.Replace("source ",""),$Target)
                        Set-Content $depsDir\paket.lock $lock
                    }
                    else{
                        $_
                    }
                    $i++
                }
                else{
                    $_
                }
            }) -join "`r`n"
            $Path
            "DEPS"
            $deps
            "LOCK"
            "$depsDir\paket.lock"
            Set-Content $depsDir\paket.dependencies $deps
        }
    }
    
    end {
        
    }
}