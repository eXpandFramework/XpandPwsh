
function Invoke-PaketUpdate {
    [CmdletBinding()]
    [CmdLetTag(("#nuget","#paket"))]
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
            Push-Location $_.DirectoryName
            $installed=Invoke-PaketShowInstalled |Where-Object{$_.Id -eq $ID}
            if ($installed -and $Version){
                if (([version]$installed.Version) -ne ([version]$Version)){
                    "$ID $($installed.Version) found, updating to $Version"
                    $regex = [regex] "(?n)nuget (?<id>$ID)(?<op> [^\d]*)(?<version>\d*\.\d*\.\d*[^ \r\n]*)"
                    $depsContent=Get-Content $_ -Raw
                    $result = $regex.Replace($depsContent, "nuget `${id}`${op}$Version")
                    if (!$regex.IsMatch($depsContent)){
                        $regex = [regex] "(?n)nuget (?<id>$ID)"
                        $result = $regex.Replace($depsContent, "nuget `${id} $Version")
                    }
                    Set-Content $_ $result.Trim()
                }
                
            }
            else{
                Invoke-Script {dotnet paket update @xtraArgs}
            }
            Pop-Location
        }
    }
    
    end {
        
    }
}