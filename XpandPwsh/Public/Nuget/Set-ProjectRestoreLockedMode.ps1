function Set-ProjectRestoreLockedMode {
    [CmdletBinding(DefaultParameterSetName="Project")]
    [CmdLetTag("#nuget")]
    param (
        [parameter(Mandatory,ValueFromPipeline,ParameterSetName="Project",Position=0)]
        [xml]$Project,
        [parameter(Mandatory,ValueFromPipeline,ParameterSetName="File",Position=0)]
        [System.IO.FileInfo]$ProjectFile,
        [parameter(Position=1)]
        [bool]$Value=$true
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin        
    }
    
    process {
        if ($PSCmdlet.ParameterSetName -eq "File"){
            $Project=Get-XmlContent $ProjectFile.FullName
        }
        Update-ProjectProperty  $Project RestorePackagesWithLockFile $Value
        Update-ProjectProperty  $Project RestoreLockedMode $Value
        Update-ProjectProperty  $Project NoWarn NU1603
        Update-ProjectProperty  $Project DisableImplicitNuGetFallbackFolder $Value
        
        if ($PSCmdlet.ParameterSetName -eq "File"){
            if (!$Value){
                $lockFile="$($ProjectFile.DirectoryName)\packages.lock.json"
                if (Test-Path $lockFile){
                    Remove-Item  $lockFile
                }
            }
            $include=$Project.Project.ItemGroup.Content|Where-Object{$_.Include -eq "packages.lock.json"}
            if ($include){
                $include.ParentNode.RemoveChild($include)
            }
            $Project|Save-Xml $ProjectFile.FullName|Out-Null
        }
    }
    
    end {
        
    }
}
