function Restore-ProjectReference {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [System.IO.FileInfo]$Project,
        [parameter(Mandatory)]
        [string]$NameMatch,
        [System.IO.DirectoryInfo[]]$AssembliesPath,
        [switch]$KeepRestoreLockMode,
        [switch]$SkipResolve,
        [string]$Configuration="Debug"
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        if ($SkipResolve){
            $assembliesDictionnary=New-GenericObject -PredifinedType StringDictionary
            $AssembliesPath|ForEach-Object{
                Get-ChildItem $_.FullName *.dll|Where-Object{$_.BaseName -match $NameMatch}|ForEach-Object{
                    if (!$assembliesDictionnary.ContainsKey($_.BaseName)){
                        $assembliesDictionnary[$_.BaseName]=$_
                    }
                }
            }
            $allAssemblies=$assembliesDictionnary.Values|Get-Item
        }
        $env:configuration=$Configuration
    }
    
    process {
        Get-Variable Project|Out-Variable
        Remove-PackageReference  $Project $NameMatch|Out-Null
        [xml]$csproj=Get-XmlContent $Project.FullName
        $msBuildProject= Read-MSBuildProject $Project.FullName
        $outputPath=[System.IO.Path]::Combine($Project.DirectoryName,(($msBuildProject.AllEvaluatedProperties|Where-Object{$_.name -eq "outputpath"})|Select-Object -Last 1).EvaluatedValue)
        
        Get-Variable outputPath|Out-Variable
        $extension=".dll"
        if ($csproj.Project.PropertyGroup.OutputType -like "*exe*"){
            $extension=".exe"
        }
        $assemblyName="$($csproj.Project.PropertyGroup.Assemblyname|Select-Object -First 1)"
        if (!$assemblyName){
            $assemblyName=$Project.BaseName
        }
        $assemblyName+=$extension
        
        if (Test-Path "$outputPath\$assemblyName"){
            if (!$SkipResolve){
                Get-AssemblyReference "$outputPath\$assemblyName" -NameFilter $NameMatch -Recurse|ForEach-Object{
                    $hintPath=$outputPath
                    if ($AssembliesPath){
                        $name=$_.Name
                        $hintPath=$AssembliesPath|Where-Object{
                            $path="$_\$($name).dll"
                            if (Test-Path $path){
                                $path
                            }
                        }|select-object -first 1
                        if (!$hintPath){
                            throw "$($_.name) not found in assembliespath"
                        }
                    }
                    Add-ProjectReference $csproj -Include $_.Name -HintPath "$hintPath\$($_.Name).dll"|Out-Null
                }
            }
            else{
                $allAssemblies|ForEach-Object{
                    Add-ProjectReference $csproj -Include $_.BaseName -HintPath $_.FullName|Out-Null
                }
            }
            
        }
        else{
            Write-Error "Cannot find $outputPath\$assemblyName"
        }
        $csproj|Save-Xml $Project.FullName|Out-Null
        Clear-ProjectDirectories $Project.DirectoryName
        if (!$KeepRestoreLockMode){
            Set-ProjectRestoreLockedMode $Project $false
        }
        
    }
    
    end {
        
    }
}
