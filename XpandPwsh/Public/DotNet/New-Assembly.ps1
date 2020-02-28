function New-Assembly {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#dotnetcore"))]
    param (
        [parameter(Mandatory)]
        [string]$AssemblyName,
        [parameter(Mandatory,ParameterSetName="code")]
        [string]$Code,
        [parameter(Mandatory,ParameterSetName="files",ValueFromPipeline)]
        [string[]]$Files,
        [parameter()]
        [string[]]$Packages=@(),
        [parameter()]
        [string]$OutputPath="$PSScriptRoot\$assemblyName",
        [ValidateSet("console","classlib")]
        [string]$Template="classlib",
        [ValidateSet("netstandard2.0","netcoreapp2.1","netcoreapp2.2","netcoreapp3.0")]
        [string]$Framework="netstandard2.0",
        [ValidateSet("Debug","Release")]
        [string]$Configuration="Release"
    )
    
    begin {
    }
    
    process {
        Push-location $env:TEMP
        if (Test-Path "$env:TEMP\$assemblyName"){
            get-childitem "$env:TEMP\$assemblyName" -Recurse|Remove-Item -ErrorAction Continue -Force -Recurse
        }
        dotnet new $Template --name $assemblyName --force -f $Framework
        Push-Location $AssemblyName
        $location=get-location
        [xml]$csproj=Get-Content "$location\$AssemblyName.csproj"
        $element=$csproj.CreateElement("CopyLocalLockFileAssemblies")
        $propertyGroup=$csproj.Project.PropertyGroup
        $propertyGroup.AppendChild($element)
        $propertyGroup.CopyLocalLockFileAssemblies="true"
        $csproj.Save("$location\$AssemblyName.csproj")
        Get-ChildItem *.cs |Remove-Item
        $packages |ForEach-Object{dotnet add package $_}
        if($PSCmdlet.ParameterSetName -eq "code"){
            $code|Out-file ".\$assemblyName.cs" -encoding UTF8
        }
        else{
            $files|Copy-Item -Destination .
        }
        
        $publish=dotnet publish -c $Configuration -f $Framework -o $OutputPath 
        if ($LASTEXITCODE){
            throw   "Fail to publish $assemblyName`r`n`r`n$publish"
        }
        $publish
        Pop-Location
        Pop-Location
        "$OutputPath\$AssemblyName.dll"
    }
    
    end {
    }
}