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
             
            Invoke-Script{ffmpeg -i $GifPath.FullName -movflags faststart -pix_fmt yuv420p -hide_banner -loglevel panic $OutputFile}
            Get-Item $OutputFile
        }
    }
    
    end {
        
    }
}