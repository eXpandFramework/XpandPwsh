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
            ffmpeg -i $Video.Name -c copy -map 0 -segment_time $Segment -f segment "$($Video.BaseName)%03d$($Video.Extension)"
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