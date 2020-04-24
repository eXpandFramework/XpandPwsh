function ConvertTo-Image {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [string]$Text,
        [parameter(Mandatory)]
        [string]$OutputFile,
        [int]$Density=1200,
        [int]$Quality=100,
        [int]$MaximumSizeBytes,
        [int]$MaximumWidth
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        Install-Chocolatey
        if (!(Get-ChocoPackage imagemagick.app)){
            choco install imagemagick.app
        }
        $ImageMagick=Get-ChildItem ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ProgramFiles)) "ImageMagick*"|ForEach-Object{
            Get-ChildItem $_.FullName magick.exe
        }|Select-Object -First 1
        if (!(Get-ChocoPackage Ghostscript)){
            choco install Ghostscript
        }
        npm install -g pretty-markdown-pdf|Out-Null
        
    }
    
    process {
        $baseName=[System.IO.Path]::GetFileNameWithoutExtension($OutputFile)
        Push-Location $env:TEMP
        Remove-Item $baseName -Force -Recurse -ErrorAction SilentlyContinue
        New-Item $baseName -ItemType Directory
        Push-Location $baseName
        $mdFile=".\$baseName.md"
        Set-Content $mdFile $Text
        Invoke-Script{pretty-md-pdf -i $mdFile}
        $pdfName=".\$baseName.pdf"
        
        do {
            $jpgName=[guid]::NewGuid()
            Invoke-Script{& $ImageMagick -density $Density -quality $Quality $pdfName .\$jpgName.jpg }
            if ($MaximumWidth){
                $bmp=[System.Drawing.Bitmap]::new((Get-Item .\$jpgName.jpg).FullName)
                if ($bmp.Width -gt $MaximumWidth){
                    Invoke-Script{& $ImageMagick .\$jpgName.jpg -resize $MaximumWidth ".\$jpgName.resized.jpg"}
                    $jpgName="$jpgName.resized"
                }
            }
            Invoke-Script{& $ImageMagick .\$jpgName.jpg -flatten -fuzz 1% -trim +repage ".\$jpgName.trim.jpg" }
            $jpgName="$jpgName.trim"
            Invoke-Script{
                & $ImageMagick ".\$jpgName.jpg" -border 2%x2% $OutputFile
            }
            $Density=0.9*$Density    
            $Quality=0.9*$Quality    
            
        } until (!$MaximumSizeBytes -or (([System.IO.File]::ReadAllBytes($OutputFile)).Length -lt $MaximumSizeBytes))
        Pop-Location
        Pop-Location
    }
    
    end {
        
    }
}