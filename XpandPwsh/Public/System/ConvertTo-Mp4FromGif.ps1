function ConvertTo-Mp4FromGif {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [System.IO.FileInfo]$GifPath,
        [parameter()]
        [string]$OutputFile
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        if (!(Get-Chocopackage ffmpeg)){
            Install-ChocoPackage ffmpeg
        }
        
    }
    
    process {
        Invoke-Script{
            if (!$OutputFile){
                $OutputFile="$($GifPath.DirectoryName)\$($GifPath.BaseName).mp4"
            }
            Remove-Item $OutputFile -ErrorAction SilentlyContinue
            ffmpeg -i $GifPath.FullName -movflags faststart -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" $OutputFile
            Get-Item $OutputFile
        }
    }
    
    end {
        
    }
}