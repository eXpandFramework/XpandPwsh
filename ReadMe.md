[![](https://img.shields.io/powershellgallery/v/XpandPosh.svg?style=flat)](https://www.powershellgallery.com/packages/XpandPosh) [![](https://img.shields.io/powershellgallery/dt/XpandPosh.svg?style=flat)](https://www.powershellgallery.com/packages/XpandPosh)
# About
The module exports 73 Cmdlets that can help you automate your every day tasks. The module is used in production from the eXpandFramework [build scripts](https://github.com/eXpandFramework/eXpand/blob/master/Support/Build/Build.ps1) and [Azure Tasks](https://github.com/eXpandFramework/Azure-Tasks).

In this page you can see a list of all Cmdlets with a short description. For details and real world examples search the [Wiki](https://github.com/eXpandFramework/XpandPosh/wiki).
## Installation
`XpandPosh` is available in `PSGallery`. Open a PowerShell prompt and type:
```ps1
Install-Module XpandPosh
```
## Exported Functions-Cmdlets
To list the module command issue the next line into a PowerShell prompt.
```ps1
Get-Command -Module XpandPosh
```
|Cmdlet|Synopsis|
|---|---|
|[Checkpoint-GitHubIssue](https://github.com/eXpandFramework/XpandPosh/wiki/Checkpoint-GitHubIssue)|Adds unique comments to a GitHub issue containing templated info from related commits.|
|[Clear-NugetCache](https://github.com/eXpandFramework/XpandPosh/wiki/Clear-NugetCache)|Clears all local nuget caches.|
|[Clear-ProjectDirectories](https://github.com/eXpandFramework/XpandPosh/wiki/Clear-ProjectDirectories)|Removes recursively common directories like bin, obj, .vs, packages|
|[Close-GithubIssue](https://github.com/eXpandFramework/XpandPosh/wiki/Close-GithubIssue)|Close a GitHub Issue based on its last update.|
|[Compress-Project](https://github.com/eXpandFramework/XpandPosh/wiki/Compress-Project)|Compress all files for a VS Solution|
|[ConvertTo-Object](https://github.com/eXpandFramework/XpandPosh/wiki/ConvertTo-Object)|{{ Fill in the Synopsis }}|
|[ConvertTo-PackageObject](https://github.com/eXpandFramework/XpandPosh/wiki/ConvertTo-PackageObject)||
|[Disable-ExecutionPolicy](https://github.com/eXpandFramework/XpandPosh/wiki/Disable-ExecutionPolicy)|{{ Fill in the Synopsis }}|
|[Find-XpandNugetPackage](https://github.com/eXpandFramework/XpandPosh/wiki/Find-XpandNugetPackage)|Finds only eXpandFramework packages.|
|[Find-XpandPackage](https://github.com/eXpandFramework/XpandPosh/wiki/Find-XpandPackage)||
|[Get-AssemblyInfoVersion](https://github.com/eXpandFramework/XpandPosh/wiki/Get-AssemblyInfoVersion)|Returns the version of an AssemblyInfo.cs|
|[Get-CallerPreference](https://github.com/eXpandFramework/XpandPosh/wiki/Get-CallerPreference)|Fetches "Preference" variable values from the caller's scope.|
|[Get-ChocoPackage](https://github.com/eXpandFramework/XpandPosh/wiki/Get-ChocoPackage)|{{ Fill in the Synopsis }}|
|[Get-DevExpressVersion](https://github.com/eXpandFramework/XpandPosh/wiki/Get-DevExpressVersion)|Returns the DevExpress version depending on the parameter set used.|
|[Get-Distinct](https://github.com/eXpandFramework/XpandPosh/wiki/Get-Distinct)|{{ Fill in the Synopsis }}|
|[Get-DotNetCoreVersion](https://github.com/eXpandFramework/XpandPosh/wiki/Get-DotNetCoreVersion)||
|[Get-DxNugets](https://github.com/eXpandFramework/XpandPosh/wiki/Get-DxNugets)||
|[Get-GitHubCommitIssue](https://github.com/eXpandFramework/XpandPosh/wiki/Get-GitHubCommitIssue)|Lists all GitHub issues that related to a commit.|
|[Get-GitHubIssue](https://github.com/eXpandFramework/XpandPosh/wiki/Get-GitHubIssue)|List Github issues for a repository.|
|[Get-GitHubMilestone](https://github.com/eXpandFramework/XpandPosh/wiki/Get-GitHubMilestone)|Returns github repository milestones.|
|[Get-GitHubRelease](https://github.com/eXpandFramework/XpandPosh/wiki/Get-GitHubRelease)|Returns github repository releases.|
|[Get-GitHubRepositoryTag](https://github.com/eXpandFramework/XpandPosh/wiki/Get-GitHubRepositoryTag)|Returns GitHub repository tags.|
|[Get-GitLastSha](https://github.com/eXpandFramework/XpandPosh/wiki/Get-GitLastSha)|Returns the Sha of the last git commit.|
|[Get-MsBuildPath](https://github.com/eXpandFramework/XpandPosh/wiki/Get-MsBuildPath)|Returns the MSBuild path.|
|[Get-NugetPackage](https://github.com/eXpandFramework/XpandPosh/wiki/Get-NugetPackage)|Download and extract a NuGet package without installing it.|
|[Get-NugetPackageDownloadsCount](https://github.com/eXpandFramework/XpandPosh/wiki/Get-NugetPackageDownloadsCount)|Get the downloads of a NuGet packages|
|[Get-NugetPackageMetadataVersion](https://github.com/eXpandFramework/XpandPosh/wiki/Get-NugetPackageMetadataVersion)|{{ Fill in the Synopsis }}|
|[Get-NugetPackageSearchMetadata](https://github.com/eXpandFramework/XpandPosh/wiki/Get-NugetPackageSearchMetadata)|Returns only the metadata of a NuGet package.|
|[Get-NugetPath](https://github.com/eXpandFramework/XpandPosh/wiki/Get-NugetPath)|Download Nuget.exe if not exists and returns its path.|
|[Get-PackageFeed](https://github.com/eXpandFramework/XpandPosh/wiki/Get-PackageFeed)|Returns common package feeds like Nuget.org and Xpand.|
|[Get-PackageSourceLocations](https://github.com/eXpandFramework/XpandPosh/wiki/Get-PackageSourceLocations)|Returns the locations of the registered in the system package feeds.|
|[Get-RelativePath](https://github.com/eXpandFramework/XpandPosh/wiki/Get-RelativePath)|Returns the relative path needed to move from one location to another.|
|[Get-SymbolSources](https://github.com/eXpandFramework/XpandPosh/wiki/Get-SymbolSources)|List the sources of a symbol (*.pdb)|
|[Get-XmlContent](https://github.com/eXpandFramework/XpandPosh/wiki/Get-XmlContent)|{{ Fill in the Synopsis }}|
|[Get-XpandPath](https://github.com/eXpandFramework/XpandPosh/wiki/Get-XpandPath)|{{ Fill in the Synopsis }}|
|[Get-XpandVersion](https://github.com/eXpandFramework/XpandPosh/wiki/Get-XpandVersion)||
|[Install-Chocolatey](https://github.com/eXpandFramework/XpandPosh/wiki/Install-Chocolatey)|{{ Fill in the Synopsis }}|
|[Install-DebugOptimizationHook](https://github.com/eXpandFramework/XpandPosh/wiki/Install-DebugOptimizationHook)|Installs system wide hook for disabling debugging optimizations|
|[Install-DevExpress](https://github.com/eXpandFramework/XpandPosh/wiki/Install-DevExpress)|Installs all DevExpress assemblies needed for all solutions under a directory.|
|[Install-SubModule](https://github.com/eXpandFramework/XpandPosh/wiki/Install-SubModule)|{{ Fill in the Synopsis }}|
|[Install-Xpand](https://github.com/eXpandFramework/XpandPosh/wiki/Install-Xpand)|This is the eXpandFramework main installer.|
|[Invoke-AzureRestMethod](https://github.com/eXpandFramework/XpandPosh/wiki/Invoke-AzureRestMethod)|Invokes Azure DevOps REST API|
|[Invoke-Parallel](https://github.com/eXpandFramework/XpandPosh/wiki/Invoke-Parallel)|Invokes tasks in parallel.|
|[Invoke-Retry](https://github.com/eXpandFramework/XpandPosh/wiki/Invoke-Retry)|Retry on error.|
|[New-Command](https://github.com/eXpandFramework/XpandPosh/wiki/New-Command)|{{ Fill in the Synopsis }}|
|[New-GithubReleaseNotes](https://github.com/eXpandFramework/XpandPosh/wiki/New-GithubReleaseNotes)|Generates GitHub Release notes.|
|[New-GithubReleaseNotesTemplate](https://github.com/eXpandFramework/XpandPosh/wiki/New-GithubReleaseNotesTemplate)|{{ Fill in the Synopsis }}|
|[Publish-AssemblyToGac](https://github.com/eXpandFramework/XpandPosh/wiki/Publish-AssemblyToGac)|Publish assemblies to Gac.|
|[Publish-GitHubRelease](https://github.com/eXpandFramework/XpandPosh/wiki/Publish-GitHubRelease)|{{ Fill in the Synopsis }}|
|[Publish-NugetPackage](https://github.com/eXpandFramework/XpandPosh/wiki/Publish-NugetPackage)|Publishes a NuGet package.|
|[Remove-ProjectLicenseFile](https://github.com/eXpandFramework/XpandPosh/wiki/Remove-ProjectLicenseFile)|Removes licx files from a VS project.|
|[Remove-ProjectNuget](https://github.com/eXpandFramework/XpandPosh/wiki/Remove-ProjectNuget)|{{ Fill in the Synopsis }}|
|[Set-VsoVariable](https://github.com/eXpandFramework/XpandPosh/wiki/Set-VsoVariable)|{{ Fill in the Synopsis }}|
|[Test-Symbol](https://github.com/eXpandFramework/XpandPosh/wiki/Test-Symbol)|Checks if the symbol is valid for a given assembly.|
|[Uninstall-ProjectAllPackages](https://github.com/eXpandFramework/XpandPosh/wiki/Uninstall-ProjectAllPackages)|Uninstall all NuGet and their dependencies from a project.|
|[UnInstall-Xpand](https://github.com/eXpandFramework/XpandPosh/wiki/UnInstall-Xpand)|Uninstall eXpandFramework project.|
|[UnPublish-NugetPackage](https://github.com/eXpandFramework/XpandPosh/wiki/UnPublish-NugetPackage)|Unpublish Nuget packages from a source.|
|[Update-AssemblyInfo](https://github.com/eXpandFramework/XpandPosh/wiki/Update-AssemblyInfo)|Updates the AssemblyInfo.cs version|
|[Update-AssemblyInfoVersion](https://github.com/eXpandFramework/XpandPosh/wiki/Update-AssemblyInfoVersion)|Updates the AssemblyInfo.cs version|
|[Update-GitHubIssue](https://github.com/eXpandFramework/XpandPosh/wiki/Update-GitHubIssue)|Update a GitHub issue.|
|[Update-HintPath](https://github.com/eXpandFramework/XpandPosh/wiki/Update-HintPath)|Update VS project HintPath.|
|[Update-NugetPackage](https://github.com/eXpandFramework/XpandPosh/wiki/Update-NugetPackage)|Update VS project NuGet packages to their latest version found from all registered in the system sources.|
|[Update-NugetProjectVersion](https://github.com/eXpandFramework/XpandPosh/wiki/Update-NugetProjectVersion)|Update the version found in AssemblyInfo.cs looking in Git history for any midification since the last tag.|
|[Update-OutputPath](https://github.com/eXpandFramework/XpandPosh/wiki/Update-OutputPath)|Updates VS project output path.|
|[Update-ProjectAutoGenerateBindingRedirects](https://github.com/eXpandFramework/XpandPosh/wiki/Update-ProjectAutoGenerateBindingRedirects)|Enables AutoGenerateBindingRedirects for a VS project.|
|[Update-ProjectDebugSymbols](https://github.com/eXpandFramework/XpandPosh/wiki/Update-ProjectDebugSymbols)|Enable Debug Symbols for a VS Project.|
|[Update-ProjectLanguageVersion](https://github.com/eXpandFramework/XpandPosh/wiki/Update-ProjectLanguageVersion)|Update Project language version to `Latest`|
|[Update-ProjectPackage](https://github.com/eXpandFramework/XpandPosh/wiki/Update-ProjectPackage)|Calls the `Update-NugetPackage` cmdlet from inside VS Package Manager Console|
|[Update-ProjectProperty](https://github.com/eXpandFramework/XpandPosh/wiki/Update-ProjectProperty)|Update a VS project property.|
|[Update-ProjectSign](https://github.com/eXpandFramework/XpandPosh/wiki/Update-ProjectSign)|Signs a VS project.|
|[Update-ProjectTargetFramework](https://github.com/eXpandFramework/XpandPosh/wiki/Update-ProjectTargetFramework)|Update the Target Framework in a MSBuild project.|
|[Update-Symbols](https://github.com/eXpandFramework/XpandPosh/wiki/Update-Symbols)|Index symbols to local or remote locations.|
|[Use-NugetAssembly](https://github.com/eXpandFramework/XpandPosh/wiki/Use-NugetAssembly)|{{ Fill in the Synopsis }}|
 
