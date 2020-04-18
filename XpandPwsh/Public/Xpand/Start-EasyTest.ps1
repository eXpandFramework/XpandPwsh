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
    }
    
    process {
        Start-SqlLocalDB
        $DXVersion=Get-VersionPart (Get-AssemblyVersion (Get-ChildItem $AssembliesDirectory "DevExpress.ExpressApp*.dll"|Select-Object -First 1)) Build
        $nugetFolder=Get-NugetInstallationFolder
        "DevExpress.EasyTest.TestExecutor","DevExpress.EasyTest","DevExpress.ExpressApp.EasyTest.WebAdapter","DevExpress.ExpressApp.EasyTest.WinAdapter"|ForEach-Object{
            Install-NugetPackage $_ $DXVersion -Source $DXFeed
            Get-ChildItem "$nugetFolder\$_\$DXVersion" -Include *.dll,*.exe -Recurse|Copy-Item -destination $AssembliesDirectory -Force
        }
        if (Test-Path $EasyTestDirectory\TestsLog.xml){
            Remove-Item $EasyTestDirectory\TestsLog.xml
        }
        Get-ChildItem $EasyTestDirectory -Include $TestFilter -Recurse|ForEach-Object{
            $testFileInfo=$_
            Invoke-Script{
                & "$AssembliesDirectory\TestExecutor.v$(Get-VersionPart $DXVersion Minor).exe" $testFileInfo.FullName
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