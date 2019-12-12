[![Build Status](https://dev.azure.com/eXpandDevOps/eXpandFramework/_apis/build/status/XpandPwsh?branchName=master)](https://dev.azure.com/eXpandDevOps/eXpandFramework/_build/latest?definitionId=45&branchName=master) [![](https://img.shields.io/powershellgallery/v/XpandPwsh.svg?style=flat)](https://www.powershellgallery.com/packages/XpandPwsh) [![](https://img.shields.io/powershellgallery/dt/XpandPwsh.svg?style=flat)](https://www.powershellgallery.com/packages/XpandPwsh)
# About
The module exports 174 Cmdlets that can help you automate your every day tasks. The module is used in production from the eXpandFramework [build scripts](https://github.com/eXpandFramework/eXpand/blob/master/Support/Build/Build.ps1) and [Azure Tasks](https://github.com/eXpandFramework/Azure-Tasks).

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
|[Add-NuspecDependency](https://github.com/eXpandFramework/XpandPwsh/wiki/Add-NuspecDependency)|{{ Fill in the Synopsis }}|
|[Checkpoint-GitHubIssue](https://github.com/eXpandFramework/XpandPwsh/wiki/Checkpoint-GitHubIssue)|Adds unique comments to a GitHub issue containing templated info from related commits.|
|[Clear-DotNetSdkFallBackFolder](https://github.com/eXpandFramework/XpandPwsh/wiki/Clear-DotNetSdkFallBackFolder)|Clears the NugetFallbackFolder|
|[Clear-NugetCache](https://github.com/eXpandFramework/XpandPwsh/wiki/Clear-NugetCache)|Clears all local nuget caches.|
|[Clear-ProjectDirectories](https://github.com/eXpandFramework/XpandPwsh/wiki/Clear-ProjectDirectories)|Removes recursively common directories like bin, obj, .vs, packages|
|[Clear-TempFolders](https://github.com/eXpandFramework/XpandPwsh/wiki/Clear-TempFolders)|Clears Windows Temp folder|
|[Close-GithubIssue](https://github.com/eXpandFramework/XpandPwsh/wiki/Close-GithubIssue)|Close a GitHub Issue based on its last update.|
|[Compress-Files](https://github.com/eXpandFramework/XpandPwsh/wiki/Compress-Files)|{{ Fill in the Synopsis }}|
|[Compress-Project](https://github.com/eXpandFramework/XpandPwsh/wiki/Compress-Project)|Compress all files for a VS Solution|
|[ConvertTo-Object](https://github.com/eXpandFramework/XpandPwsh/wiki/ConvertTo-Object)|{{ Fill in the Synopsis }}|
|[ConvertTo-PackageObject](https://github.com/eXpandFramework/XpandPwsh/wiki/ConvertTo-PackageObject)|Converts nuget.exe commands output.|
|[Disable-ExecutionPolicy](https://github.com/eXpandFramework/XpandPwsh/wiki/Disable-ExecutionPolicy)|{{ Fill in the Synopsis }}|
|[Find-NugetPackageInstallationFolder](https://github.com/eXpandFramework/XpandPwsh/wiki/Find-NugetPackageInstallationFolder)|Finds the installation path of a nuget package out of a predefined set of directories.|
|[Find-XpandNugetPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/Find-XpandNugetPackage)|Finds only eXpandFramework packages.|
|[Find-XpandPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/Find-XpandPackage)|Find eXpandFrameoWork only packages.|
|[Format-Xml](https://github.com/eXpandFramework/XpandPwsh/wiki/Format-Xml)|Pretty-print formatted XML source|
|[Get-AssemblyInfoVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-AssemblyInfoVersion)|Returns the version of an AssemblyInfo.cs|
|[Get-AssemblyMetadata](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-AssemblyMetadata)|{{ Fill in the Synopsis }}|
|[Get-AssemblyPublicKey](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-AssemblyPublicKey)|{{ Fill in the Synopsis }}|
|[Get-CallerPreference](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-CallerPreference)|Fetches "Preference" variable values from the caller's scope.|
|[Get-ChocoPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-ChocoPackage)|{{ Fill in the Synopsis }}|
|[Get-DevExpressPath](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-DevExpressPath)|{{ Fill in the Synopsis }}|
|[Get-DevExpressVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-DevExpressVersion)|Returns the DevExpress version depending on the parameter set used.|
|[Get-Distinct](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-Distinct)|{{ Fill in the Synopsis }}|
|[Get-DotNetCoreVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-DotNetCoreVersion)|Returns all installed sdks.|
|[Get-DxNugets](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-DxNugets)|Lists all assemblies in a DevExpress Nuget package.|
|[Get-GitHubCommitIssue](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitHubCommitIssue)|Lists all GitHub issues that related to a commit.|
|[Get-GitHubIssue](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitHubIssue)|List Github issues for a repository.|
|[Get-GitHubIssueComment](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitHubIssueComment)|Returns the comments of a GitHub Issue.|
|[Get-GitHubMilestone](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitHubMilestone)|Returns github repository milestones.|
|[Get-GitHubRelease](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitHubRelease)|Returns github repository releases.|
|[Get-GitHubRepositoryTag](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitHubRepositoryTag)|Returns GitHub repository tags.|
|[Get-GitLastSha](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitLastSha)|Returns the Sha of the last git commit.|
|[Get-LatestMinorVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-LatestMinorVersion)|{{ Fill in the Synopsis }}|
|[Get-MsBuildPath](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-MsBuildPath)|Returns the MSBuild path.|
|[Get-NugetInstallationFolder](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-NugetInstallationFolder)|{{ Fill in the Synopsis }}|
|[Get-NugetPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-NugetPackage)|Download and extract a NuGet package without installing it.|
|[Get-NugetPackageDownloadsCount](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-NugetPackageDownloadsCount)|Get the downloads of a NuGet packages|
|[Get-NugetPackageMetadataVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-NugetPackageMetadataVersion)|{{ Fill in the Synopsis }}|
|[Get-NugetPackageSearchMetadata](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-NugetPackageSearchMetadata)|Returns only the metadata of a NuGet package.|
|[Get-NugetPath](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-NugetPath)|Download Nuget.exe if not exists and returns its path.|
|[Get-PackageFeed](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-PackageFeed)|Returns common package feeds like Nuget.org and Xpand.|
|[Get-PackageSourceLocations](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-PackageSourceLocations)|Returns the locations of the registered in the system package feeds.|
|[Get-PackageTargetFramework](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-PackageTargetFramework)|{{ Fill in the Synopsis }}|
|[Get-ProjectTargetFramework](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-ProjectTargetFramework)|{{ Fill in the Synopsis }}|
|[Get-ReferenceConflict](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-ReferenceConflict)|{{ Fill in the Synopsis }}|
|[Get-RelativePath](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-RelativePath)|Returns the relative path needed to move from one location to another.|
|[Get-SymbolSources](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-SymbolSources)|List the sources of a symbol (*.pdb)|
|[Get-VSPath](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-VSPath)|{{ Fill in the Synopsis }}|
|[Get-XmlContent](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XmlContent)|{{ Fill in the Synopsis }}|
|[Get-XpandPackages](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XpandPackages)|Lists all Xpand Nuget package (Release/Lab)|
|[Get-XpandPath](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XpandPath)|{{ Fill in the Synopsis }}|
|[Get-XpandReleaseChange](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XpandReleaseChange)|Query all eXpandFramework releases.|
|[Get-XpandRepository](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XpandRepository)|{{ Fill in the Synopsis }}|
|[Get-XpandVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XpandVersion)|Returns eXpandFramework version for several scenarios.|
|[Install-Chocolatey](https://github.com/eXpandFramework/XpandPwsh/wiki/Install-Chocolatey)|{{ Fill in the Synopsis }}|
|[Install-DebugOptimizationHook](https://github.com/eXpandFramework/XpandPwsh/wiki/Install-DebugOptimizationHook)|Installs system wide hook for disabling debugging optimizations|
|[Install-DevExpress](https://github.com/eXpandFramework/XpandPwsh/wiki/Install-DevExpress)|Installs all DevExpress assemblies needed for all solutions under a directory.|
|[Install-SubModule](https://github.com/eXpandFramework/XpandPwsh/wiki/Install-SubModule)|{{ Fill in the Synopsis }}|
|[Install-Xpand](https://github.com/eXpandFramework/XpandPwsh/wiki/Install-Xpand)|This is the eXpandFramework main installer.|
|[Invoke-AzureRestMethod](https://github.com/eXpandFramework/XpandPwsh/wiki/Invoke-AzureRestMethod)|Invokes Azure DevOps REST API|
|[Invoke-Parallel](https://github.com/eXpandFramework/XpandPwsh/wiki/Invoke-Parallel)|Invokes tasks in parallel.|
|[Invoke-Retry](https://github.com/eXpandFramework/XpandPwsh/wiki/Invoke-Retry)|Retry on error.|
|[New-Assembly](https://github.com/eXpandFramework/XpandPwsh/wiki/New-Assembly)|{{ Fill in the Synopsis }}|
|[New-AssemblyResolver](https://github.com/eXpandFramework/XpandPwsh/wiki/New-AssemblyResolver)|{{ Fill in the Synopsis }}|
|[New-Command](https://github.com/eXpandFramework/XpandPwsh/wiki/New-Command)|{{ Fill in the Synopsis }}|
|[New-GitHubComment](https://github.com/eXpandFramework/XpandPwsh/wiki/New-GitHubComment)|{{ Fill in the Synopsis }}|
|[New-GithubReleaseNotes](https://github.com/eXpandFramework/XpandPwsh/wiki/New-GithubReleaseNotes)|Generates GitHub Release notes.|
|[New-GithubReleaseNotesTemplate](https://github.com/eXpandFramework/XpandPwsh/wiki/New-GithubReleaseNotesTemplate)|{{ Fill in the Synopsis }}|
|[Publish-AssemblyToGac](https://github.com/eXpandFramework/XpandPwsh/wiki/Publish-AssemblyToGac)|Publish assemblies to Gac.|
|[Publish-GitHubRelease](https://github.com/eXpandFramework/XpandPwsh/wiki/Publish-GitHubRelease)|{{ Fill in the Synopsis }}|
|[Publish-NugetPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/Publish-NugetPackage)|Publishes a NuGet package.|
|[Remove-BlankLines](https://github.com/eXpandFramework/XpandPwsh/wiki/Remove-BlankLines)|Removes blank lines from a files|
|[Remove-ProjectLicenseFile](https://github.com/eXpandFramework/XpandPwsh/wiki/Remove-ProjectLicenseFile)|Removes licx files from a VS project.|
|[Remove-ProjectNuget](https://github.com/eXpandFramework/XpandPwsh/wiki/Remove-ProjectNuget)|{{ Fill in the Synopsis }}|
|[Resolve-AssemblyDependencies](https://github.com/eXpandFramework/XpandPwsh/wiki/Resolve-AssemblyDependencies)|Resolve all referenced assemblies for a given assembly, reclusively.|
|[Set-VsoVariable](https://github.com/eXpandFramework/XpandPwsh/wiki/Set-VsoVariable)|{{ Fill in the Synopsis }}|
|[Start-SelfElevate](https://github.com/eXpandFramework/XpandPwsh/wiki/Start-SelfElevate)|Elevates the current powershell session|
|[Start-XpandProjectConverter](https://github.com/eXpandFramework/XpandPwsh/wiki/Start-XpandProjectConverter)|Updates versions of eXpandFramework assemblies in csproj files when the eXpandFramework installer is used|
|[Switch-DevExpress](https://github.com/eXpandFramework/XpandPwsh/wiki/Switch-DevExpress)|Switch csproj DevExpress references to Nuget packages|
|[Test-Symbol](https://github.com/eXpandFramework/XpandPwsh/wiki/Test-Symbol)|Checks if the symbol is valid for a given assembly.|
|[Uninstall-ProjectAllPackages](https://github.com/eXpandFramework/XpandPwsh/wiki/Uninstall-ProjectAllPackages)|Uninstall all NuGet and their dependencies from a project.|
|[UnInstall-Xpand](https://github.com/eXpandFramework/XpandPwsh/wiki/UnInstall-Xpand)|Uninstall eXpandFramework project.|
|[UnPublish-NugetPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/UnPublish-NugetPackage)|Unpublish Nuget packages from a source.|
|[Update-AssemblyInfo](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-AssemblyInfo)|Updates the AssemblyInfo.cs version|
|[Update-AssemblyInfoVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-AssemblyInfoVersion)|Updates the AssemblyInfo.cs version|
|[Update-GitHubIssue](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-GitHubIssue)|Update a GitHub issue.|
|[Update-HintPath](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-HintPath)|Update VS project HintPath.|
|[Update-NugetPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-NugetPackage)|Update VS project NuGet packages to their latest version found from all registered in the system sources.|
|[Update-NugetProjectVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-NugetProjectVersion)|Update the version found in AssemblyInfo.cs looking in Git history for any midification since the last tag.|
|[Update-Nuspec](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-Nuspec)|{{ Fill in the Synopsis }}|
|[Update-OutputPath](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-OutputPath)|Updates VS project output path.|
|[Update-ProjectAutoGenerateBindingRedirects](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-ProjectAutoGenerateBindingRedirects)|Enables AutoGenerateBindingRedirects for a VS project.|
|[Update-ProjectDebugSymbols](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-ProjectDebugSymbols)|Enable Debug Symbols for a VS Project.|
|[Update-ProjectLanguageVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-ProjectLanguageVersion)|Update Project language version to `Latest`|
|[Update-ProjectPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-ProjectPackage)|Calls the `Update-NugetPackage` cmdlet from inside VS Package Manager Console|
|[Update-ProjectProperty](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-ProjectProperty)|Update a VS project property.|
|[Update-ProjectSign](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-ProjectSign)|Signs a VS project.|
|[Update-ProjectTargetFramework](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-ProjectTargetFramework)|Update the Target Framework in a MSBuild project.|
|[Update-Symbols](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-Symbols)|Index symbols to local or remote locations.|
|[Use-MonoCecil](https://github.com/eXpandFramework/XpandPwsh/wiki/Use-MonoCecil)|{{ Fill in the Synopsis }}|
|[Use-NugetAssembly](https://github.com/eXpandFramework/XpandPwsh/wiki/Use-NugetAssembly)|{{ Fill in the Synopsis }}|
 
