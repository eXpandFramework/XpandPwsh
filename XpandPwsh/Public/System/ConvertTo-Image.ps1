function ConvertTo-Image {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [string]$Text,
        [parameter(Mandatory)]
        [string]$OutputFile,
        [int]$Density=1200,
        [int]$Quality=100
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
        $baseName=[guid]::NewGuid().ToString()
        Push-Location $env:TEMP
        $mdFile=".\$baseName.md"
        Set-Content $mdFile $Text
        pretty-md-pdf -i $mdFile
        & $ImageMagick -density $Density -quality $Quality "$baseName.pdf" .\$baseName.jpg 
        & $ImageMagick .\$baseName.jpg -flatten -fuzz 1% -trim +repage $OutputFile
        Pop-Location
    }
    
    end {
        
    }
}