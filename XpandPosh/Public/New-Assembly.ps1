function New-Assembly {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        $AssemblyName,
        [parameter(Mandatory)]
        $Code,
        [parameter()]
        $Packages=@(),
        [parameter()]
        $path="$PSScriptRoot\$assemblyName",
        [ValidateSet("console","classlib")]
        $template="classlib",
        [ValidateSet("netstandard2.0","netcoreapp2.1","netcoreapp2.2","netcoreapp3.0")]
        $framework="netstandard2.0",
        [ValidateSet("Debug","Release")]
        $configuration="Release"
    )
    
    begin {
    }
    
    process {
        & {
            push-location $env:TEMP
            if (Test-Path "$env:TEMP\$assemblyName"){
                get-childitem "$env:TEMP\$assemblyName" -Recurse|Remove-Item -ErrorAction Continue -Force -Recurse
            }
            dotnet new $template --name $assemblyName --force -f $framework
            Push-Location $AssemblyName
            Get-ChildItem *.cs |Remove-Item
            $packages |ForEach-Object{dotnet add package $_}
            
            $code|Out-file ".\$assemblyName.cs" -encoding UTF8
            dotnet publish -c $configuration -f $framework -o $path 
            if ($LASTEXITCODE){
                throw   "Fail to publish $assemblyName"
            }
            Pop-Location
            Pop-Location
        }|Write-Verbose
        "$path\$AssemblyName.dll"
    }
    
    end {
    }
}