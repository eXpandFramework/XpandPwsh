
function Invoke-PaketInstall {
    [CmdletBinding()]
    [CmdLetTag(("#nuget","#paket"))]
    param (
        [parameter(ValueFromPipeline)]
        [switch]$Force,
        [switch]$Strict
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
            
            Write-Host "Paket Install at $($_.DirectoryName)" -f Blue
            Push-Location $_.DirectoryName
            Invoke-Script{dotnet paket install @xtraArgs}
            Pop-Location
        }
    }
    
    end {
        
    }
}