[CmdletBinding()]

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
                Invoke-Script{ffmpeg -v warning -i $Video.FullName -vf "$filters,palettegen=stats_mode=diff" -y $palette}
                for ($i = 0; $i -lt $Parts; $i++) {
                    Invoke-Script{ffmpeg -i $Video.Name -i $palette -lavfi "$filters,paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" -ss ("{0:hh\:mm\:ss}" -f ([TimeSpan] $startTime)) -t $Segment -async 1 -y "$($Video.BaseName)$i$($Video.Extension)" }
                    $startTime+=$Segment
                }
            }
            else{
                ffmpeg -i $Video.Name -c copy -segment_time $Segment -f segment "$($Video.BaseName)%03d$($Video.Extension)"
            }
            
            Get-ChildItem "$($Video.BaseName)*$($Video.Extension)"|Select-Object -Skip 1
            
        }
        else{
            Invoke-Script{ffmpeg -i $Video.Name -ss $From -to $To -c copy output.mp4}
        }
        Pop-Location
    }
    
    end {
        
    }