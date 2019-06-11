[![Build Status](https://dev.azure.com/eXpandDevOps/eXpandFramework/_apis/build/status/XpandPwsh?branchName=master)](https://dev.azure.com/eXpandDevOps/eXpandFramework/_build/latest?definitionId=45&branchName=master) [![](https://img.shields.io/powershellgallery/v/XpandPwsh.svg?style=flat)](https://www.powershellgallery.com/packages/XpandPwsh) [![](https://img.shields.io/powershellgallery/dt/XpandPwsh.svg?style=flat)](https://www.powershellgallery.com/packages/XpandPwsh)
# About
The module exports 81 Cmdlets that can help you automate your every day tasks. The module is used in production from the eXpandFramework [build scripts](https://github.com/eXpandFramework/eXpand/blob/master/Support/Build/Build.ps1) and [Azure Tasks](https://github.com/eXpandFramework/Azure-Tasks).

In this page you can see a list of all Cmdlets with a short description. For details and real world examples search the [Wiki](https://github.com/eXpandFramework/XpandPwsh/wiki).
## Installation
`XpandPwsh` is available in `PSGallery`. Open a PowerShell prompt and type:
```ps1
Install-Module XpandPwsh
```
## Exported Functions-Cmdlets
To list the module command issue the next line into a PowerShell prompt.
```ps1
Get-Command -Module XpandPwsh
```
|Cmdlet|Synopsis|
|---|---|
|[Checkpoint-GitHubIssue](https://github.com/eXpandFramework/XpandPwsh/wiki/Checkpoint-GitHubIssue)|Adds unique comments to a GitHub issue containing templated info from related commits.|
|[Clear-NugetCache](https://github.com/eXpandFramework/XpandPwsh/wiki/Clear-NugetCache)|{{ Fill in the Synopsis }}|
|[Clear-ProjectDirectories](https://github.com/eXpandFramework/XpandPwsh/wiki/Clear-ProjectDirectories)|{{ Fill in the Synopsis }}|
|[Close-GithubIssue](https://github.com/eXpandFramework/XpandPwsh/wiki/Close-GithubIssue)|Close a GitHub Issue based on its last update.|
|[Compress-Project](https://github.com/eXpandFramework/XpandPwsh/wiki/Compress-Project)|{{ Fill in the Synopsis }}|
|[ConvertTo-Object](https://github.com/eXpandFramework/XpandPwsh/wiki/ConvertTo-Object)|{{ Fill in the Synopsis }}|
|[ConvertTo-PackageObject](https://github.com/eXpandFramework/XpandPwsh/wiki/ConvertTo-PackageObject)|{{ Fill in the Synopsis }}|
|[Disable-ExecutionPolicy](https://github.com/eXpandFramework/XpandPwsh/wiki/Disable-ExecutionPolicy)|{{ Fill in the Synopsis }}|
|[Find-XpandNugetPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/Find-XpandNugetPackage)|Finds only eXpandFramework packages.|
|[Find-XpandPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/Find-XpandPackage)|{{ Fill in the Synopsis }}|
|[Get-AssemblyInfoVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-AssemblyInfoVersion)|{{ Fill in the Synopsis }}|
|[Get-CallerPreference](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-CallerPreference)|Fetches "Preference" variable values from the caller's scope.|
|[Get-ChocoPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-ChocoPackage)|{{ Fill in the Synopsis }}|
|[Get-DevExpressVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-DevExpressVersion)|{{ Fill in the Synopsis }}|
|[Get-Distinct](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-Distinct)|{{ Fill in the Synopsis }}|
|[Get-DotNetCoreVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-DotNetCoreVersion)|{{ Fill in the Synopsis }}|
|[Get-DxNugets](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-DxNugets)|{{ Fill in the Synopsis }}|
|[Get-GitHubCommitIssue](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitHubCommitIssue)|Lists all GitHub issues that related to a commit.|
|[Get-GitHubIssue](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitHubIssue)|List Github issues for a repository.|
|[Get-GitHubIssueComment](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitHubIssueComment)|Returns the comments of a GitHub Issue.|
|[Get-GitHubMilestone](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitHubMilestone)|Returns github repository milestones.|
|[Get-GitHubRelease](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitHubRelease)|Returns github repository releases.|
|[Get-GitHubRepositoryTag](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitHubRepositoryTag)|Returns GitHub repository tags.|
|[Get-GitLastSha](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitLastSha)|{{ Fill in the Synopsis }}|
|[Get-MsBuildPath](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-MsBuildPath)|{{ Fill in the Synopsis }}|
|[Get-NugetPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-NugetPackage)|Download and extract a NuGet package without installing it.|
|[Get-NugetPackageDownloadsCount](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-NugetPackageDownloadsCount)|Get the downloads of a NuGet packages|
|[Get-NugetPackageMetadataVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-NugetPackageMetadataVersion)|{{ Fill in the Synopsis }}|
|[Get-NugetPackageSearchMetadata](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-NugetPackageSearchMetadata)|Returns only the metadata of a NuGet package.|
|[Get-NugetPath](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-NugetPath)|{{ Fill in the Synopsis }}|
|[Get-PackageFeed](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-PackageFeed)|{{ Fill in the Synopsis }}|
|[Get-PackageSourceLocations](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-PackageSourceLocations)|{{ Fill in the Synopsis }}|
|[Get-RelativePath](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-RelativePath)|{{ Fill in the Synopsis }}|
|[Get-SymbolSources](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-SymbolSources)|{{ Fill in the Synopsis }}|
|[Get-XmlContent](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XmlContent)|{{ Fill in the Synopsis }}|
|[Get-XpandPackages](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XpandPackages)|{{ Fill in the Synopsis }}|
|[Get-XpandPath](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XpandPath)|{{ Fill in the Synopsis }}|
|[Get-XpandReleaseChange](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XpandReleaseChange)|{{ Fill in the Synopsis }}|
|[Get-XpandVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XpandVersion)|{{ Fill in the Synopsis }}|
|[Install-Chocolatey](https://github.com/eXpandFramework/XpandPwsh/wiki/Install-Chocolatey)|{{ Fill in the Synopsis }}|
|[Install-DebugOptimizationHook](https://github.com/eXpandFramework/XpandPwsh/wiki/Install-DebugOptimizationHook)|{{ Fill in the Synopsis }}|
|[Install-DevExpress](https://github.com/eXpandFramework/XpandPwsh/wiki/Install-DevExpress)|{{ Fill in the Synopsis }}|
|[Install-SubModule](https://github.com/eXpandFramework/XpandPwsh/wiki/Install-SubModule)|{{ Fill in the Synopsis }}|
|[Install-Xpand](https://github.com/eXpandFramework/XpandPwsh/wiki/Install-Xpand)|{{ Fill in the Synopsis }}|
|[Invoke-AzureRestMethod](https://github.com/eXpandFramework/XpandPwsh/wiki/Invoke-AzureRestMethod)|{{ Fill in the Synopsis }}|
|[Invoke-Parallel](https://github.com/eXpandFramework/XpandPwsh/wiki/Invoke-Parallel)|Invokes tasks in parallel.|
|[Invoke-Retry](https://github.com/eXpandFramework/XpandPwsh/wiki/Invoke-Retry)|{{ Fill in the Synopsis }}|
|[New-Assembly](https://github.com/eXpandFramework/XpandPwsh/wiki/New-Assembly)|{{ Fill in the Synopsis }}|
|[New-AssemblyResolver](https://github.com/eXpandFramework/XpandPwsh/wiki/New-AssemblyResolver)|{{ Fill in the Synopsis }}|
|[New-Command](https://github.com/eXpandFramework/XpandPwsh/wiki/New-Command)|{{ Fill in the Synopsis }}|
|[New-GithubReleaseNotes](https://github.com/eXpandFramework/XpandPwsh/wiki/New-GithubReleaseNotes)|Generates GitHub Release notes.|
|[New-GithubReleaseNotesTemplate](https://github.com/eXpandFramework/XpandPwsh/wiki/New-GithubReleaseNotesTemplate)|{{ Fill in the Synopsis }}|
|[Publish-AssemblyToGac](https://github.com/eXpandFramework/XpandPwsh/wiki/Publish-AssemblyToGac)|{{ Fill in the Synopsis }}|
|[Publish-GitHubRelease](https://github.com/eXpandFramework/XpandPwsh/wiki/Publish-GitHubRelease)|{{ Fill in the Synopsis }}|
|[Publish-NugetPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/Publish-NugetPackage)|{{ Fill in the Synopsis }}|
|[Remove-ProjectLicenseFile](https://github.com/eXpandFramework/XpandPwsh/wiki/Remove-ProjectLicenseFile)|{{ Fill in the Synopsis }}|
|[Remove-ProjectNuget](https://github.com/eXpandFramework/XpandPwsh/wiki/Remove-ProjectNuget)|{{ Fill in the Synopsis }}|
|[Resolve-AssemblyDependencies](https://github.com/eXpandFramework/XpandPwsh/wiki/Resolve-AssemblyDependencies)|Resolve all referenced assemblies for a given assembly, reclusively.|
|[Set-VsoVariable](https://github.com/eXpandFramework/XpandPwsh/wiki/Set-VsoVariable)|{{ Fill in the Synopsis }}|
|[Sort-PackageByDependencies](https://github.com/eXpandFramework/XpandPwsh/wiki/Sort-PackageByDependencies)|{{ Fill in the Synopsis }}|
|[Test-Symbol](https://github.com/eXpandFramework/XpandPwsh/wiki/Test-Symbol)|{{ Fill in the Synopsis }}|
|[Uninstall-ProjectAllPackages](https://github.com/eXpandFramework/XpandPwsh/wiki/Uninstall-ProjectAllPackages)|{{ Fill in the Synopsis }}|
|[UnInstall-Xpand](https://github.com/eXpandFramework/XpandPwsh/wiki/UnInstall-Xpand)|{{ Fill in the Synopsis }}|
|[UnPublish-NugetPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/UnPublish-NugetPackage)|{{ Fill in the Synopsis }}|
|[Update-AssemblyInfo](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-AssemblyInfo)|{{ Fill in the Synopsis }}|
|[Update-AssemblyInfoVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-AssemblyInfoVersion)|{{ Fill in the Synopsis }}|
|[Update-GitHubIssue](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-GitHubIssue)|Update a GitHub issue.|
|[Update-HintPath](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-HintPath)|{{ Fill in the Synopsis }}|
|[Update-NugetPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-NugetPackage)|{{ Fill in the Synopsis }}|
|[Update-NugetProjectVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-NugetProjectVersion)|Update the version found in AssemblyInfo.cs looking in Git history for any midification since the last tag.|
|[Update-OutputPath](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-OutputPath)|{{ Fill in the Synopsis }}|
|[Update-ProjectAutoGenerateBindingRedirects](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-ProjectAutoGenerateBindingRedirects)|{{ Fill in the Synopsis }}|
|[Update-ProjectDebugSymbols](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-ProjectDebugSymbols)|{{ Fill in the Synopsis }}|
|[Update-ProjectLanguageVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-ProjectLanguageVersion)|{{ Fill in the Synopsis }}|
|[Update-ProjectPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-ProjectPackage)|{{ Fill in the Synopsis }}|
|[Update-ProjectProperty](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-ProjectProperty)|{{ Fill in the Synopsis }}|
|[Update-ProjectSign](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-ProjectSign)|{{ Fill in the Synopsis }}|
|[Update-ProjectTargetFramework](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-ProjectTargetFramework)|{{ Fill in the Synopsis }}|
|[Update-Symbols](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-Symbols)|{{ Fill in the Synopsis }}|
|[Use-MonoCecil](https://github.com/eXpandFramework/XpandPwsh/wiki/Use-MonoCecil)|{{ Fill in the Synopsis }}|
|[Use-NugetAssembly](https://github.com/eXpandFramework/XpandPwsh/wiki/Use-NugetAssembly)|{{ Fill in the Synopsis }}|
 
