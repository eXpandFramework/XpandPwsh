
function Invoke-PaketUpdate {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)]
        [switch]$Force,
        [switch]$Strict,
        [switch]$NotInteractive
    )
    
    begin {
        
    }
    
    process {
        $depArgs=@{
            Strict=$Strict
        }
        Get-PaketDependenciesPath @depArgs |ForEach-Object{
            $xtraArgs = @();
            if ($Force) {
                $xtraArgs += "--force"
            }
            Write-Host "Paket Update at $($_.DirectoryName)" -f Blue
            Push-Location $dir
            dotnet paket update @xtraArgs
            Pop-Location
        }
    }
    
    end {
        
    }
}