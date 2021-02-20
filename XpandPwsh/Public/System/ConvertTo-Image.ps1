function ConvertTo-Image {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [string]$Text,
        [parameter(Mandatory)]
        [string]$OutputFile,
        [int]$MaximumSizeBytes,
        [int]$MaximumWidth,
        [int]$Width,
        [int]$MinimumCanvasHeight
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        $ImageMagick=Install-ImageMagic
        Install-NpmPackage pretty-markdown-pdf|Out-Null
    }
    
    process {
        $baseName=[System.IO.Path]::GetFileNameWithoutExtension($OutputFile)
        Push-Location $env:TEMP
        Remove-Item $baseName -Force -Recurse -ErrorAction SilentlyContinue
        New-Item $baseName -ItemType Directory|Out-Null
        Push-Location $baseName
        $mdFile=".\$baseName.md"
        Set-Content $mdFile $Text
        Invoke-Script{pretty-md-pdf -i $mdFile -t png}
        $baseName=[System.IO.Path]::GetFileNameWithoutExtension($OutputFile)
        Invoke-Script{& "$ImageMagick" .\$baseName.png -flatten -fuzz 1% -trim +repage ".\$baseName.trim.png" }
        $baseName="$baseName.trim"
        Invoke-Script{& "$ImageMagick" .\$baseName.png -bordercolor white -border 20 ".\$baseName.border.png" }
        $baseName="$baseName.border"
        if ($Width){
            $bmp=[System.Drawing.Bitmap]::new((Get-Item .\$baseName.png).FullName)
            if ($bmp.Width -ne $Width){
                Invoke-Script{& "$ImageMagick" .\$baseName.png -resize $Width ".\$baseName.resizedWidth.png" }
                $baseName="$baseName.resizedWidth"
            }
            $bmp.Dispose()
        }
        $resize=100
        do {
            if ($MaximumWidth){
                $bmp=[System.Drawing.Bitmap]::new((Get-Item .\$baseName.png).FullName)
                if ($bmp.Width -gt $MaximumWidth){
                    Invoke-Script{& "$ImageMagick" .\$baseName.png -resize $MaximumWidth ".\$baseName.resized.png" }
                    $baseName="$baseName.resized"
                }
                $MaximumWidth=$MaximumWidth*0.9
                $bmp.Dispose()
            }
            
            if ($MinimumCanvasHeight){
                $bmp=[System.Drawing.Bitmap]::new((Get-Item .\$baseName.png).FullName)
                if ($bmp.Height -lt $MinimumCanvasHeight){
                    Invoke-Script{& "$ImageMagick" convert .\$baseName.png -background none -gravity center -extent "$($bmp.Width)x$MinimumCanvasHeight" ".\$baseName.extendCanvas.png" }
                    $baseName="$baseName.extendCanvas"
                }
                $bmp.Dispose()
            }
            $size=([System.IO.File]::ReadAllBytes("$(Get-Location)\$baseName.png")).Length
            if ($MaximumSizeBytes -and ($size -gt $MaximumSizeBytes)){
                $resize-=5
                Invoke-Script{& "$ImageMagick" .\$baseName.png -resize "$resize%" ".\$baseName.maximumsize.png" }
                $baseName="$baseName.maximumsize"
                $size=([System.IO.File]::ReadAllBytes("$(Get-Location)\$baseName.png")).Length
            }
        } while ($MaximumSizeBytes -and ($size -gt $MaximumSizeBytes))
        Copy-Item ".\$baseName.png" $OutputFile -Force 
        Pop-Location
        Pop-Location
    }
    
    end {
        
    }
}