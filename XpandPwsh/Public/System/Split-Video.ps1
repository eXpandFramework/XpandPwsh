function Split-Video{
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [System.IO.FileInfo]$Video,
        [parameter(ParameterSetName="time")]
        [timespan]$From=[timespan]::Zero,
        [parameter(Mandatory,ParameterSetName="time")]
        [timespan]$To,
        [parameter(Mandatory,ParameterSetName="parts")]
        [int]$Parts

    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        if (!(Get-Chocopackage ffmpeg)){
            Install-ChocoPackage ffmpeg
        }
    }
    
    process {
        Push-Location $Video.DirectoryName
        if ($Parts){
            $partTime=[timespan]::FromSeconds((Get-VideoInfo -video $Video).duration/$parts)
            $Segment="{0:hh\:mm\:ss}" -f ([TimeSpan] $partTime)
            $startTime=([TimeSpan]::Zero)
            
            if ($Video.Extension -match "Gif" ){
                $filters="scale=-1:-1:flags=lanczos"
                $palette="$env:TEMP\palette.png"
                for ($i = 0; $i -lt $Parts; $i++) {
                    ffmpeg -i $Video.Name -i $palette -lavfi "$filters,paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" -ss ("{0:hh\:mm\:ss}" -f ([TimeSpan] $startTime)) -t $Segment -async 1 -y "$($Video.BaseName)$i$($Video.Extension)" 
                    $startTime+=$Segment
                }
            }
            else{
                ffmpeg -i $Video.Name -c copy -segment_time $Segment -f segment "$($Video.BaseName)%03d$($Video.Extension)"
            }
            
            Get-ChildItem "$($Video.BaseName)*$($Video.Extension)"|Select-Object -Skip 1
            
        }
        else{
            Invoke-Script{
                $endtime=$startTime+$partTime
                ffmpeg -i $Video.Name -ss $From -to $To -c copy output.mp4
                $startTime+=$partTime
            }
        }
        Pop-Location
    }
    
    end {
        
    }
}