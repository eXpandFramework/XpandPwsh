function Start-EasyTest {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory)]
        [string]$AssembliesDirectory,
        [parameter(ValueFromPipeline,Mandatory)]
        [string]$EasyTestDirectory,
        [parameter(Mandatory)]
        [string]$DXFeed,
        [parameter()]
        [string[]]$TestFilter,
        [parameter()]
        [int]$RetryOnFailure=0
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        $easyTestBin="$AssembliesDirectory\EasyTest\bin"
        Remove-Item -Force -Recurse -Path "$easyTestBin\.." -ErrorAction SilentlyContinue
        New-Item $easyTestBin -ItemType Directory -Force
    }
    
    process {
        Start-SqlLocalDB
        $DXVersion=Get-VersionPart (Get-AssemblyVersion (Get-ChildItem $AssembliesDirectory "DevExpress.ExpressApp*.dll"|Select-Object -First 1)) Build
        Install-NugetPackage DevExpress.EasyTest.TestExecutor $DXVersion -Source $DXFeed -OutputDirectory "$easyTestBin\.."
        Get-ChildItem -Path "$easyTestBin\.." -Include *.dll,*.exe -Recurse | Where-Object {$_.FullName -notlike "*\netstandard*\*"} | Copy-Item -Destination $easyTestBin 
        Copy-Item "C:\Program Files (x86)\Microsoft.NET\Primary Interop Assemblies\Microsoft.mshtml.dll" -Destination $easyTestBin 
        Get-ChildItem $EasyTestDirectory -Include $TestFilter -Recurse|ForEach-Object{
            $testFileInfo=$_
            Invoke-Script{
                & "$easyTestBin\TestExecutor.v$(Get-VersionPart $DXVersion Minor).exe" $testFileInfo.FullName
                [xml]$log=Get-xmlContent $EasyTestDirectory\TestsLog.xml  
                $test=($log.Tests.Test|Where-Object{$_.Name -eq $testFileInfo.BaseName})
                if (!$test -or ($test.Result -in "Failed","Warning")){
                    throw "$($test.Error.Message.'#cdata-section')`r`n`r`n$($test.Error.Stack)"
                }
            } -Maximum $RetryOnFailure
        }
    }
    
    end {
    }
}