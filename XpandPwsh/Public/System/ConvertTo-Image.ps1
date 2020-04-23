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
        [int]$MaximumSizeBytes
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
        
        do {
            & $ImageMagick -density $Density -quality $Quality "$baseName.pdf" .\$baseName.jpg 
            & $ImageMagick .\$baseName.jpg -flatten -fuzz 1% -trim +repage $OutputFile
            $Density=0.9*$Density    
            $Quality=0.9*$Quality    
        } until (!$MaximumSizeBytes -or (([System.IO.File]::ReadAllBytes($OutputFile)).Length -lt $MaximumSizeBytes))
        Pop-Location
    }
    
    end {
        
    }
}