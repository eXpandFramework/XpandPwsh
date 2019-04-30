function Publish-NugetPackage {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [string]$NupkgPath,
        [parameter(Mandatory)]
        [string]$Source,
        [parameter(Mandatory)]
        [string]$ApiKey
    )
    
    begin {
        if (!(Test-Path $NupkgPath)){
            throw "$NupkgPath is not a valid path"
        }
        $Nuget=Get-NugetPath
    }
    
    process {
        $packages=(& $Nuget List -source $NupkgPath)|convertto-packageobject
        Write-Verbose "Packages found:"
        $packages|Write-Verbose
        
        $published=$packages|Select-Object -ExpandProperty Id| Invoke-Parallel -activityName "Getting latest versions from sources" -VariablesToImport @("Source") -Script  { 
            Get-NugetPackageSearchMetadata -Name $_ -Sources $Source
        } 
        Write-Verbose "Published packages:"
        $published=$published|Select-object -ExpandProperty Metadata|Get-NugetPackageMetadataVersion
        $published|Write-Verbose 
        
        $needPush=$packages|Where-Object{
            $p=$_
            $published |Where-Object{
                $_.Name -eq $p.Name -and $_.Version -eq $_.Version
            }
        }
        Write-Verbose "NeedPush"
        $needPush|Write-Verbose 
        $NupkgPath=$NupkgPath.TrimEnd("\")
        $publishScript={        
            $package="$NupkgPath\$($_.Name).$($_.Version).nupkg"
            "Pushing $package in $Source "
            & $Nuget Push "$package" -ApiKey $ApiKey -source $Source
        }
        
        $needPush|Invoke-Parallel -ActivityName "Publishing Nugets" -VariablesToImport @("ApiKey","NupkgPath","Source","Nuget") -Script $publishScript
     
    }
    end {
    }
}