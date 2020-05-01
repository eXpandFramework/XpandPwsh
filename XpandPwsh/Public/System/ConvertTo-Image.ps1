function ConvertTo-Image {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [string]$Text,
        [parameter(Mandatory)]
        [string]$OutputFile,
        [int]$MaximumSizeBytes,
        [int]$MaximumWidth
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        $ImageMagick=Install-ImageMagic
        Install-NpmPackage pretty-markdown-pdf|Out-Null
        $Text+="`r`n`r`n"
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
            $MaximumWidth=$MaximumWidth*0.9
        } while ($MaximumSizeBytes -and (([System.IO.File]::ReadAllBytes("$(Get-Location)\$baseName.png")).Length -gt $MaximumSizeBytes))
        Copy-Item ".\$baseName.png" $OutputFile -Force 
        Pop-Location
        Pop-Location
    }
    
    end {
        
    }
}