function Join-Video {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(ValueFromPipeline)]
        [System.IO.FileInfo]$Video,
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
        
        Push-Location $Video.DirectoryName
        $transCode="$($Video.BaseName).ts"
        Remove-Item $transCode -Force -ErrorAction SilentlyContinue
        $files+=$transCode
        Invoke-Script{
            ffmpeg -i $Video.Name -c copy -bsf:v h264_mp4toannexb -f mpegts $transCode
        }
        Pop-Location
    }
    
    end {
        Remove-Item $OutputFile -ErrorAction SilentlyContinue
        Invoke-Script{
            ffmpeg -i "concat:$(($files|Join-String -Separator '|'))" -c copy -bsf:a aac_adtstoasc $OutputFile
        }
        $files|Remove-Item
    }
}