function ConvertTo-GifFromMp4 {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [System.IO.FileInfo]$Mp4Path,
        [parameter()]
        [string]$OutputFile,
        [int]$FrameRate=7,
        [int]$Width=-1
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
                $OutputFile="$($Mp4Path.DirectoryName)\$($Mp4Path.BaseName).gif"
            }
            Remove-Item $OutputFile -ErrorAction SilentlyContinue
            ffmpeg -i $Mp4Path -vf "fps=$frameRate,scale=$Width`:-1:flags=lanczos" $OutputFile
            Get-Item $OutputFile
        }
    }
    
    end {
        
    }
}