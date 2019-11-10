
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
        $paketExe=(Get-PaketPath $path)
        if ($paketExe){
            $depsDir=(Get-item $paketExe).Directory.Parent.FullName
            $i=0;
            $deps=(Get-Content $depsDir\paket.dependencies|ForEach-Object{
                if ($_ -like "source *"){
                    if ($Index -eq $i){
                        "source $Target"
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
            Set-Content $depsDir\paket.dependencies $deps
        }
    }
    
    end {
        
    }
}