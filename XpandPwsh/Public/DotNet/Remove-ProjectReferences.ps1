function Remove-ProjectReferences {
    [CmdletBinding()]
    [CmdLetTag("#visualstudio")]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [System.IO.FileInfo]$ProjectFile,
        [parameter()]
        [string]$ReferenceMatch,
        [switch]$InvalidHintPath,
        [switch]$NotInGac
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        if ($NotInGac){
            $gacAssemblies=Get-GacAssembly|ConvertTo-Dictionary -KeyPropertyName Name -ValuePropertyName Version
        }
        
    }
    
    process {
        Push-Location $ProjectFile.DirectoryName
        [xml]$csproj = Get-XmlContent $ProjectFile.FullName
        $csproj.Project.ItemGroup.Reference | ForEach-Object {
            if ($ReferenceMatch -and $_.include -match $ReferenceMatch ) {
                $_.ParentNode.RemoveChild($_)    
            }
            if ($InvalidHintPath -and $_.HintPath){
                if ([System.IO.Path]::IsPathRooted($_.HintPath) -or !(Resolve-Path $_.HintPath -ErrorAction SilentlyContinue)){
                    $_.ParentNode.RemoveChild($_)    
                }
            }
            if ($NotInGac){
                $include=$_.include
                $index=$include.indexof(",")
                if ($index -gt -1){
                    $include=$include.substring(0,$index)
                }
                if ($include -notin $gacAssemblies.Name){
                    $_.ParentNode.RemoveChild($_)    
                }
            }
        }
        $csproj | Save-Xml $ProjectFile.FullName
        Pop-Location
    }
    
    end {
    }
}