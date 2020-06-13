function ConvertTo-Mp4FromGif {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [System.IO.FileInfo]$GifPath,
        [parameter(Mandatory)]
        [string]$OutputFile,
        [int]$FrameRate=12
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        $ImageMagick=Install-ImageMagic
        if (!(Get-Chocopackage ffmpeg)){
            Install-ChocoPackage ffmpeg
        }
    }
    
    process {
        $baseName=[System.IO.Path]::GetFileNameWithoutExtension($OutputFile)
        $pngFolder="$($GifPath.DirectoryName)\$($GifPath.BaseName)"
        Remove-Item $pngFolder -ErrorAction SilentlyContinue -Force -Recurse
        New-Item -path $pngFolder -ItemType Directory
        Push-Location $pngFolder
        & "$ImageMagick" convert $GifPath gif%05d.png
        ffmpeg -f image2 -r 30 -i gif%05d.png -y -an OUTPUT.mp4 
        ffmpeg -f image2 -i gif%05d.png -r 30 -c:v libx264 timelapse.mp4 
        # ffmpeg -r 12 -i gif%05d.png -c:v libx264 -vf fps=25 -pix_fmt yuv420p out.mp4
        # ffmpeg -f image2 -r 60 -s 1920x1080 -i gif%05d.png -vcodec libx264 -crf 25  -pix_fmt yuv420p test.mp4
        ffmpeg -i .\wWuVntKJ8q.gif -movflags faststart -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" video.mp4

        Remove-Item $baseName -Force -Recurse -ErrorAction SilentlyContinue
        New-Item $baseName -ItemType Directory|Out-Null
        Push-Location $baseName
        $mdFile=".\$baseName.md"
        Set-Content $mdFile $Text
        Invoke-Script{pretty-md-pdf -i $mdFile -t png}
        do {
            $baseName=[System.IO.Path]::GetFileNameWithoutExtension($OutputFile)
            if ($MaximumWidth){
                $bmp=[System.Drawing.Bitmap]::new((Get-Item .\$baseName.png).FullName)
                if ($bmp.Width -gt $MaximumWidth){
                    Invoke-Script{& "$ImageMagick" .\$baseName.png -resize $MaximumWidth ".\$baseName.resized.png" }
                    $baseName="$baseName.resized"
                }
            }
            Invoke-Script{& "$ImageMagick" .\$baseName.png -flatten -fuzz 1% -trim +repage ".\$baseName.trim.png" }
            $baseName=".\$baseName.trim"
            Invoke-Script{& "$ImageMagick" .\$baseName.png -bordercolor white -border 20 ".\$baseName.border.png" }
            $baseName=".\$baseName.border"
            $MaximumWidth=$MaximumWidth*0.9
        } while ($MaximumSizeBytes -and (([System.IO.File]::ReadAllBytes("$(Get-Location)\$baseName.png")).Length -gt $MaximumSizeBytes))
        Copy-Item ".\$baseName.png" $OutputFile -Force 
        Pop-Location
        Pop-Location
    }
    
    end {
        
    }
}