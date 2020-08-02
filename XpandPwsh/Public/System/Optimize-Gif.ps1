function Optimize-Gif {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [System.IO.FileInfo]$Gif,
        [int]$frameRate=7,
        [int]$Scale=-1
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        install-npmpackage gifsicle
    }
    
    process {
        # $palette="$env:TEMP\palette.png"
        # $filters="fps=$FrameRate,scale=$Scale`:-1:flags=lanczos"
        # Invoke-Script{ffmpeg -hide_banner -loglevel panic -i $Gif.FullName -vf "$filters,palettegen=stats_mode=diff" -y $palette}
        # $ffmpegOutput="$($Gif.DirectoryName)\$($Gif.BaseName)_ffmpeg$($Gif.Extension)"
        # Invoke-Script{ffmpeg -hide_banner -loglevel panic -i $Gif.FullName -i $palette -lavfi "$filters,paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" -y $ffmpegOutput}
        $gifsicleOutput="$($Gif.DirectoryName)\$($Gif.BaseName)_optimized$($Gif.Extension)"
        Invoke-Script{gifsicle -O3 $ffmpegOutput -o $gifsicleOutput}
        Get-Item $gifsicleOutput
    }
    
    end {
        
    }
}