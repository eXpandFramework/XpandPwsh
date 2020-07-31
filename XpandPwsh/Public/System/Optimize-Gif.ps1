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
    }
    
    process {
        $palette="$env:TEMP\palette.png"
        $filters="fps=$FrameRate,scale=$Scale`:-1:flags=lanczos"
        Invoke-Script{ffmpeg -v warning -i $Gif.FullName -vf "$filters,palettegen=stats_mode=diff" -y $palette}
        $output="$($Gif.DirectoryName)\$($Gif.BaseName)_optimized$($Gif.Extension)"
        Invoke-Script{ffmpeg -v warning -i $Gif.FullName -i $palette -lavfi "$filters,paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" -y $output}
        Get-Item $output
    }
    
    end {
        
    }
}