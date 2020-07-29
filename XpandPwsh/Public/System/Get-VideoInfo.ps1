function Get-VideoInfo {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [System.IO.FileInfo]$Video
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        if (!(Get-Chocopackage ffmpeg)){
            Install-ChocoPackage ffmpeg
        }
    }
    
    process {
        (ffprobe -v quiet -print_format json -show_format -show_streams $Video.FullName |out-string|ConvertFrom-Json).streams
    }
    
    end {
        
    }
}