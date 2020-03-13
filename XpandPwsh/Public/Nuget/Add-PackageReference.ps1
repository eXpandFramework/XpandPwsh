function Add-PackageReference {
    [CmdletBinding(DefaultParameterSetName="Project")]
    [CmdLetTag("#nuget")]
    param (
        [parameter(Mandatory,ValueFromPipeline,ParameterSetName="Project")]
        [xml]$Project,
        [parameter(Mandatory,ValueFromPipeline,ParameterSetName="Project")]
        [version]$Version,
        [parameter(Mandatory,ValueFromPipeline)]
        [string]$Package,
        [parameter(ParameterSetName="Sources")]
        [string[]]$Source=(Get-PackageSourceLocations -Verbose:$false)
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        if ($PSCmdlet.ParameterSetName -ne "Project"){
            $projects=Get-ChildItem *.*proj
            if (!$projects){
                throw "Projects not found"
            }
            if ($projects.count -gt 1){
                $projects
                throw "Multiple projects found"
            }
        }
    }
    
    process {
        if ($PSCmdlet.ParameterSetName -eq "Project") {
            "package","version"|Out-VariableValue
            $existingPackage=$Project.Project.ItemGroup.PackageReference|Where-Object{$_.Include -eq $package}
            if ($existingPackage){
                $existingPackage.version=$Version
            }
            else{
                Add-XmlElement $Project PackageReference ItemGroup ([ordered]@{
                    Include = $package
                    Version = $Version
                })   
            }
            return
        }
        Use-NugetConfig -Sources $Source -ScriptBlock {
            dotnet add package $Package
        }
        
    }
    
    end {
        
    }
}