function Publish-NugetPackage {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [parameter(ValueFromPipeline)]
        [string]$NupkgPath=(Get-Location),
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
        $packages=(& $Nuget List -search $NupkgPath)|convertto-packageobject -NewFormat
        Write-Verbose "Packages found:"
        $packages|Write-Verbose
        
        $published=$packages|Select-Object -ExpandProperty Id| Get-NugetPackageSearchMetadata  -Source $Source 
        Write-Verbose "Published packages:"
        $published=$published|Get-NugetPackageMetadataVersion
        $published|Write-Verbose 
        $needPush=$packages
        if ($published){
            $needPush=$packages|Where-Object{
                $p=$_
                !($published |Where-Object{
                    $_.Name -eq $p.Id -and $_.Version -eq $p.Version
                })
            }
        }
        
        Write-Verbose "NeedPush"
        $needPush|Write-Verbose 
        $NupkgPath=$NupkgPath.TrimEnd("\")
        
        $needPush|Invoke-Parallel -ActivityName "Publishing Nugets" -VariablesToImport @("ApiKey","NupkgPath","Source","Nuget") -Script {
        # $needPush|foreach {
            $package="$NupkgPath\$($_.Id).$($_.Version).nupkg"
            Write-Output "Pushing $package in $Source "
            & $Nuget Push "$package" -ApiKey $ApiKey -source $Source
        }
     
    }
    end {
    }
}