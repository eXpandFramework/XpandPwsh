
function Invoke-PaketUpdate {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)]
        [switch]$Force,
        [switch]$Strict,
        [switch]$NotInteractive,
        [parameter(ParameterSetName="id")]
        [string]$ID,
        [parameter(ParameterSetName="id")]
        [string]$Version
    )
    
    begin {
        
    }
    
    process {
        $depArgs=@{
            Strict=$Strict
        }
        Get-PaketDependenciesPath @depArgs |ForEach-Object{
            if ($Force) {
                $xtraArgs += "--force"
            }
            Write-Host "Paket Update at $($_.DirectoryName)" -f Blue
            Push-Location $dir
            $installed=Invoke-PaketShowInstalled |Where-Object{$_.Id -eq $ID}
            if ($installed -and $Version){
                "$ID found, updating to $Version"
                $regex = [regex] "(?n)nuget (?<id>$ID)(?<op> [^\d]*)(?<version>\d*\.\d*\.\d*[^ \r\n]*)"
                $depsContent=Get-Content $_ -Raw
                $result = $regex.Replace($depsContent, "nuget `${id}`${op}$Version")
                Set-Content $_ $result.Trim()
            }
            else{
                dotnet paket update @xtraArgs
            }
            Pop-Location
        }
    }
    
    end {
        
    }
}