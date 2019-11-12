
function Invoke-PaketInstall {
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
            Write-Host "Installing Paket at $($_.DirectoryName)" -f Blue
            Push-Location $dir
            dotnet paket install @xtraArgs
            Pop-Location
        }
    }
    
    end {
        
    }
}