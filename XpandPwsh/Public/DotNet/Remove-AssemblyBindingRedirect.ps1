function Remove-AssemblyBindingRedirect {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#dotnetcore"))]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [System.IO.FileInfo]$ProjectFile
    )
    
    begin {
    }
    
    process {
        [xml]$proj=Get-XmlContent $ProjectFile 
        $dir=$ProjectFile.DirectoryName
        if (!$proj.project.propertygroup.KeepAssemblyBindingRedirect){
            $outputType=$proj.project.propertygroup.outputtype
            if ($outputType -eq "WinExe" -or (Test-Path )){
                
            }
        }
    }
    
    end {
    }
}