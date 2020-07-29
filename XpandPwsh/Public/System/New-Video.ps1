function New-Video {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [System.IO.FileInfo]$Image,
        [parameter(Mandatory)]
        [string]$OutputFile,
        [parameter(Mandatory)]
        [int]$Duration,
        [parameter(Mandatory)]
        [int]$FrameRate

    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        
    }
    
    process {
        if ([System.IO.Path]::GetExtension($OutputFile) -match "mp4"){
            ffmpeg -loop 1 -framerate $frameRate -i $image.FullName -c:v libx264 -t $Duration -pix_fmt yuv420p -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2" $outputFile 
        }
        else{
            ffmpeg -loop 1 -framerate $frameRate -i $image.FullName -t $Duration -pix_fmt yuv420p $outputFile
        }
        Get-Item $OutputFile
    }
    
    end {
        
    }
}