function Join-Video {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(ValueFromPipeline)]
        [System.IO.FileInfo[]]$Video,
        [parameter()]
        [string]$OutputFile="output.mp4"
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        if (!(Get-Chocopackage ffmpeg)){
            Install-ChocoPackage ffmpeg
        }
        $files=@()
    }
    
    process {
        $Video|ForEach-Object{
            Push-Location $_.DirectoryName
            $transCode="$($_.BaseName).ts"
            Remove-Item $transCode -Force -ErrorAction SilentlyContinue
            $files+=$transCode
            $name=$_.Name
            Invoke-Script{
                ffmpeg -i $name -c copy -bsf:v h264_mp4toannexb -f mpegts $transCode
            }
            Pop-Location
        }
    }
    
    end {
        Remove-Item $OutputFile -ErrorAction SilentlyContinue
        Push-Location (Get-Item $Video|Select-Object -First 1).DirectoryName
        Invoke-Script{
            
            ffmpeg -i "concat:$(($files|Join-String -Separator '|'))" -c copy -bsf:a aac_adtstoasc $OutputFile
            
        }
        $files|Remove-Item -ErrorAction SilentlyContinue
        Get-Item $OutputFile
        Pop-Location
    }
}