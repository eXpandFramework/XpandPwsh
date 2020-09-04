![image](https://user-images.githubusercontent.com/159464/66713086-c8c5a800-edae-11e9-9bc1-73ffc0c215fb.png)

[![Build Status](https://dev.azure.com/eXpandDevOps/eXpandFramework/_apis/build/status/XpandPwsh?branchName=master)](https://dev.azure.com/eXpandDevOps/eXpandFramework/_build/latest?definitionId=45&branchName=master) [![](https://xpandshields.azurewebsites.net/powershellgallery/v/XpandPwsh.svg?style=flat)](https://www.powershellgallery.com/packages/XpandPwsh) [![](https://xpandshields.azurewebsites.net/powershellgallery/dt/XpandPwsh.svg?style=flat)](https://www.powershellgallery.com/packages/XpandPwsh)


# About
The module exports **275 Cmdlets** that can help you automate your every day tasks. The module is used in production from the eXpandFramework [build scripts](https://github.com/eXpandFramework/eXpand/blob/master/Support/Build/Build.ps1) and [Azure Tasks](https://github.com/eXpandFramework/Azure-Tasks).

In this page you can see a list of all Cmdlets with a short description. For details and real world examples search the [Wiki](https://github.com/eXpandFramework/XpandPwsh/wiki).
## Installation
`XpandPwsh` is available in `PSGallery`. Open a PowerShell prompt and type:
```ps1
Install-Module XpandPwsh
```
## Exported Functions-Cmdlets
To list the module command issue the next line into a PowerShell prompt.
```ps1
Get-XpwshCommand #alias gxcm
```
To display the wiki help page for a specific cmdlet from your console (tab autocompletion):
```ps1
Get-XPwshHelp Get-XPwshHelp #alias gxh
```
|Cmdlet|Synopsis|
|---|---|
|[Add-AssemblyBindingRedirect](https://github.com/eXpandFramework/XpandPwsh/wiki/Add-AssemblyBindingRedirect)|Adds Assembly binding redirects for a list of packages.|
|[Add-AzBuild](https://github.com/eXpandFramework/XpandPwsh/wiki/Add-AzBuild)|Add a new AzureDevOps build to a definition.|
|[Add-AzBuildTag](https://github.com/eXpandFramework/XpandPwsh/wiki/Add-AzBuildTag)|Tag an AzureDevOps Build.|
|[Add-GacAssembly](https://github.com/eXpandFramework/XpandPwsh/wiki/Add-GacAssembly)|Install assembly into the Global Assembly Cache.|
|[Add-GitDiff](https://github.com/eXpandFramework/XpandPwsh/wiki/Add-GitDiff)|State git files using a filter.|
|[Add-NuspecDependency](https://github.com/eXpandFramework/XpandPwsh/wiki/Add-NuspecDependency)|Adds a dependency to a Nuspec file.|
|[Add-PackageReference](https://github.com/eXpandFramework/XpandPwsh/wiki/Add-PackageReference)|Adds PackageReference to an MSBuild project.|
|[Add-PackageReferenceNoWarning](https://github.com/eXpandFramework/XpandPwsh/wiki/Add-PackageReferenceNoWarning)|Filter out warnings for a PackageReference.|
|[Add-ProjectBuildEvent](https://github.com/eXpandFramework/XpandPwsh/wiki/Add-ProjectBuildEvent)|Adds MSBuild project build PostBuildEvent, PreBuildEvent.|
|[Add-ProjectReference](https://github.com/eXpandFramework/XpandPwsh/wiki/Add-ProjectReference)|Add assembly reference to an MSBuild project.|
|[Add-XmlElement](https://github.com/eXpandFramework/XpandPwsh/wiki/Add-XmlElement)|Add an XmlElement to an XmlDocument.|
|[Approve-LastExitCode](https://github.com/eXpandFramework/XpandPwsh/wiki/Approve-LastExitCode)|Throws if $lastExitCode is not zero.|
|[Checkpoint-GitHubIssue](https://github.com/eXpandFramework/XpandPwsh/wiki/Checkpoint-GitHubIssue)|Adds unique comments to a GitHub issue containing templated info from related commits.|
|[Clear-AspNetTemp](https://github.com/eXpandFramework/XpandPwsh/wiki/Clear-AspNetTemp)|Clears ASP.Net temp folders.|
|[Clear-AzStorageBlob](https://github.com/eXpandFramework/XpandPwsh/wiki/Clear-AzStorageBlob)|Clear an Azure Blob Container.|
|[Clear-DotNetSdkFallBackFolder](https://github.com/eXpandFramework/XpandPwsh/wiki/Clear-DotNetSdkFallBackFolder)|Clears the NugetFallbackFolders|
|[Clear-NugetCache](https://github.com/eXpandFramework/XpandPwsh/wiki/Clear-NugetCache)|Clears all local nuget caches.|
|[Clear-ProjectDirectories](https://github.com/eXpandFramework/XpandPwsh/wiki/Clear-ProjectDirectories)|Removes recursively common directories like bin, obj, .vs, packages|
|[Clear-TempFolders](https://github.com/eXpandFramework/XpandPwsh/wiki/Clear-TempFolders)|Clears Windows Temp folder|
|[Close-GithubIssue](https://github.com/eXpandFramework/XpandPwsh/wiki/Close-GithubIssue)|Close a GitHub Issue based on its last update.|
|[Compress-Files](https://github.com/eXpandFramework/XpandPwsh/wiki/Compress-Files)|Compress File and Directories.|
|[Compress-Project](https://github.com/eXpandFramework/XpandPwsh/wiki/Compress-Project)|Compress all files for a VS Solution|
|[Connect-Az](https://github.com/eXpandFramework/XpandPwsh/wiki/Connect-Az)|Connects to Azure using an application secret.|
|[ConvertTo-Dictionary](https://github.com/eXpandFramework/XpandPwsh/wiki/ConvertTo-Dictionary)|Converts a pipeline to a dictionary.|
|[ConvertTo-Directory](https://github.com/eXpandFramework/XpandPwsh/wiki/ConvertTo-Directory)|Convert path to directory.|
|[ConvertTo-FramedText](https://github.com/eXpandFramework/XpandPwsh/wiki/ConvertTo-FramedText)|Formats text with a customizable frame.|
|[ConvertTo-HttpQueryString](https://github.com/eXpandFramework/XpandPwsh/wiki/ConvertTo-HttpQueryString)|Converts a Hastable to an HttpQueryString.|
|[ConvertTo-Image](https://github.com/eXpandFramework/XpandPwsh/wiki/ConvertTo-Image)|{{ Fill in the Synopsis }}|
|[ConvertTo-Indexed](https://github.com/eXpandFramework/XpandPwsh/wiki/ConvertTo-Indexed)|Index a pipeline output.|
|[ConvertTo-Object](https://github.com/eXpandFramework/XpandPwsh/wiki/ConvertTo-Object)|{{ Fill in the Synopsis }}|
|[ConvertTo-PackageObject](https://github.com/eXpandFramework/XpandPwsh/wiki/ConvertTo-PackageObject)|Converts nuget.exe commands output.|
|[ConvertTo-PackageSourceLocation](https://github.com/eXpandFramework/XpandPwsh/wiki/ConvertTo-PackageSourceLocation)|Finds the location of a package source registered in global Nuget.config using its name.|
|[Disable-ExecutionPolicy](https://github.com/eXpandFramework/XpandPwsh/wiki/Disable-ExecutionPolicy)|{{ Fill in the Synopsis }}|
|[Find-Alias](https://github.com/eXpandFramework/XpandPwsh/wiki/Find-Alias)|CmdLet alias lookup.|
|[Find-History](https://github.com/eXpandFramework/XpandPwsh/wiki/Find-History)|Command line historical lookup.|
|[Find-NugetPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/Find-NugetPackage)|Fast Nuget.org lookup.|
|[Find-NugetPackageInstallationFolder](https://github.com/eXpandFramework/XpandPwsh/wiki/Find-NugetPackageInstallationFolder)|Finds the installation path of a nuget package out of a predefined set of directories.|
|[Find-PaketRefs](https://github.com/eXpandFramework/XpandPwsh/wiki/Find-PaketRefs)|Paket references lookup.|
|[Find-XpandNugetPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/Find-XpandNugetPackage)|Finds only eXpandFramework packages.|
|[Find-XpandPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/Find-XpandPackage)|Find eXpandFrameoWork only packages.|
|[Format-Text](https://github.com/eXpandFramework/XpandPwsh/wiki/Format-Text)|{{ Fill in the Synopsis }}|
|[Format-Xml](https://github.com/eXpandFramework/XpandPwsh/wiki/Format-Xml)|Pretty-print formatted XML source|
|[Get-Assembly](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-Assembly)|Checks if ASsembly is loaded to the AppDomain.|
|[Get-AssemblyInfoVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-AssemblyInfoVersion)|Returns the version of an AssemblyInfo.cs|
|[Get-AssemblyMetadata](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-AssemblyMetadata)|Lists key/value pairs of the AssemblyMetadata attribute.|
|[Get-AssemblyPublicKey](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-AssemblyPublicKey)|Returns the PublicKey of an Assembly.|
|[Get-AssemblyPublicKeyToken](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-AssemblyPublicKeyToken)|Returns the PublicKeyToken of an Assembly.|
|[Get-AssemblyReference](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-AssemblyReference)|Lists Assembly references.|
|[Get-AssemblyVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-AssemblyVersion)|Returns the Assembly Version.|
|[Get-AzArtifact](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-AzArtifact)|Download AzureDevOps Build artifacts.|
|[Get-AzBuildChanges](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-AzBuildChanges)|Download AzureDevOps Build artifacts.|
|[Get-AzBuilds](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-AzBuilds)|Lists AzureDevOps builds.|
|[Get-AzDefinition](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-AzDefinition)|Lists AzureDevOps definitions|
|[Get-AzProjects](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-AzProjects)|Returns all projects of an AzureDevops organization|
|[Get-AzTestRuns](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-AzTestRuns)|Lists AzureDevOps Test Runs.|
|[Get-CallerPreference](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-CallerPreference)|Fetches "Preference" variable values from the caller's scope.|
|[Get-ChocoPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-ChocoPackage)|{{ Fill in the Synopsis }}|
|[Get-DevExpressPath](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-DevExpressPath)|Returns the installation paths of DevExpress found in a system.|
|[Get-DevExpressVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-DevExpressVersion)|Returns the DevExpress version depending on the parameter set used.|
|[Get-Distinct](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-Distinct)|{{ Fill in the Synopsis }}|
|[Get-DotNetCoreVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-DotNetCoreVersion)|Returns all installed sdks.|
|[Get-DotNetTool](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-DotNetTool)|Lists DotNet tools.|
|[Get-DotNetVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-DotNetVersion)|Lists installed DotNet versions.|
|[Get-DXNugets](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-DXNugets)|Lists all assemblies in a DevExpress Nuget package.|
|[Get-FirstOrDefaultAsync](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-FirstOrDefaultAsync)|{{ Fill in the Synopsis }}|
|[Get-GacAssembly](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GacAssembly)|Returns Glocal Assembly Cache Assemblies.|
|[Get-GacAssemblyFile](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GacAssemblyFile)|{{ Fill in the Synopsis }}|
|[Get-GacAssemblyInstallReference](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GacAssemblyInstallReference)|{{ Fill in the Synopsis }}|
|[Get-GitDiff](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitDiff)|{{ Fill in the Synopsis }}|
|[Get-GitHubClient](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitHubClient)|{{ Fill in the Synopsis }}|
|[Get-GitHubCommitIssue](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitHubCommitIssue)|Lists all GitHub issues that related to a commit.|
|[Get-GitHubIssue](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitHubIssue)|List Github issues for a repository.|
|[Get-GitHubIssueComment](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitHubIssueComment)|Returns the comments of a GitHub Issue.|
|[Get-GitHubIssueEvents](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitHubIssueEvents)|Returns the events of a Github issue.|
|[Get-GitHubLabel](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitHubLabel)|Lists GitHub repository labels.|
|[Get-GitHubMilestone](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitHubMilestone)|Returns github repository milestones.|
|[Get-GitHubRelease](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitHubRelease)|Returns github repository releases.|
|[Get-GitHubRepositoryTag](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitHubRepositoryTag)|Returns GitHub repository tags.|
|[Get-GitLastSha](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitLastSha)|Returns the Sha of the last git commit.|
|[Get-GitRootDirectory](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitRootDirectory)|Returns the root directory of a local git repository.|
|[Get-GitTag](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitTag)|Returns a git repository tags.|
|[Get-GitUser](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-GitUser)|Returns user, mail from git config.|
|[Get-LatestMinorVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-LatestMinorVersion)|List minor versions for a Nuget Package.|
|[Get-MsBuildPath](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-MsBuildPath)|Returns the MSBuild path.|
|[Get-MSBuildProjects](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-MSBuildProjects)|Returns recursively all MSBuild for a given path.|
|[Get-NugetInstallationFolder](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-NugetInstallationFolder)|Retrieves the Nuget packages installation folders|
|[Get-NugetPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-NugetPackage)|Download and extract a NuGet package without installing it.|
|[Get-NugetPackageDependencies](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-NugetPackageDependencies)|Lists Nuget package dependencies.|
|[Get-NugetPackageDownloadsCount](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-NugetPackageDownloadsCount)|Get the downloads of a NuGet packages|
|[Get-NugetPackageMetadataVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-NugetPackageMetadataVersion)|{{ Fill in the Synopsis }}|
|[Get-NugetPackageSearchMetadata](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-NugetPackageSearchMetadata)|Returns only the metadata of a NuGet package.|
|[Get-NugetPath](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-NugetPath)|Download Nuget.exe if not exists and returns its path.|
|[Get-PackageFeed](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-PackageFeed)|Returns common package feeds like Nuget.org and Xpand.|
|[Get-PackageReference](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-PackageReference)|Lists MSBuild project PackageRefence.|
|[Get-PackageSourceLocations](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-PackageSourceLocations)|Returns the locations of the registered in the system package feeds.|
|[Get-PackageTargetFramework](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-PackageTargetFramework)|{{ Fill in the Synopsis }}|
|[Get-PaketDependenciesPath](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-PaketDependenciesPath)|Finds the paket.dependecies location searching recursively upwards.|
|[Get-PaketFiles](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-PaketFiles)|Lists Paket files.|
|[Get-PaketPackageRequirement](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-PaketPackageRequirement)|Lists Paket files.|
|[Get-ProjectTargetFramework](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-ProjectTargetFramework)|Get the TargetFramework for an MSBuild project.|
|[Get-ReferenceConflict](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-ReferenceConflict)|List all reference conflicts for a list of assemblies.|
|[Get-RelativePath](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-RelativePath)|Returns the relative path needed to move from one location to another.|
|[Get-SymbolSources](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-SymbolSources)|List the sources of a symbol (*.pdb)|
|[Get-TwitterUser](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-TwitterUser)|{{ Fill in the Synopsis }}|
|[Get-VersionPart](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-VersionPart)|Version formatting|
|[Get-VSPath](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-VSPath)|Returns Visual Studio location.|
|[Get-XAFLatestMinors](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XAFLatestMinors)|List latest XAF minor versions.|
|[Get-XAFModule](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XAFModule)|List XAF module c# classes in all assemblies in a folder.|
|[Get-XafPackageNames](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XafPackageNames)|List XAF Nuget package names for a version.|
|[Get-XmlContent](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XmlContent)|Loads an XML Document respecting namespaces.|
|[Get-XpandNugetPackageDependencies](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XpandNugetPackageDependencies)|List Xpand Nuget package dependencies.|
|[Get-XpandPackageHome](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XpandPackageHome)|Returns the Home page of an Xpand Package.|
|[Get-XpandPackageNames](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XpandPackageNames)|Lists Xpand package names.|
|[Get-XpandPackages](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XpandPackages)|Lists all Xpand Nuget package (Release/Lab)|
|[Get-XpandPath](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XpandPath)|{{ Fill in the Synopsis }}|
|[Get-XpandPublicKeyToken](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XpandPublicKeyToken)|Outputs the Xpand PublicKeyToken.|
|[Get-XpandPwshDirectoryName](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XpandPwshDirectoryName)|Outputs the XpandPwsh installation folder.|
|[Get-XpandRelease](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XpandRelease)|Returns Xpand Release hashes.|
|[Get-XpandReleaseArtifact](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XpandReleaseArtifact)|{{ Fill in the Synopsis }}|
|[Get-XpandReleaseChange](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XpandReleaseChange)|Query all eXpandFramework releases.|
|[Get-XpandRepository](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XpandRepository)|Clones an Xpand Repository or returns its url|
|[Get-XpandVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XpandVersion)|Returns eXpandFramework version for several scenarios.|
|[Get-XPwshCommand](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XPwshCommand)|Lists XpandPwsh Cmdlets.|
|[Get-XpwshHelp](https://github.com/eXpandFramework/XpandPwsh/wiki/Get-XpwshHelp)|Navigates to the online wiki page.|
|[Import-Class](https://github.com/eXpandFramework/XpandPwsh/wiki/Import-Class)|Imports a Powershell class.|
|[Install-Chocolatey](https://github.com/eXpandFramework/XpandPwsh/wiki/Install-Chocolatey)|{{ Fill in the Synopsis }}|
|[Install-DebugOptimizationHook](https://github.com/eXpandFramework/XpandPwsh/wiki/Install-DebugOptimizationHook)|Installs system wide hook for disabling debugging optimizations|
|[Install-NugetPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/Install-NugetPackage)|Install a Nuget package along with its dependencies.|
|[Install-SubModule](https://github.com/eXpandFramework/XpandPwsh/wiki/Install-SubModule)|{{ Fill in the Synopsis }}|
|[Install-Xpand](https://github.com/eXpandFramework/XpandPwsh/wiki/Install-Xpand)|This is the eXpandFramework main installer.|
|[Invoke-AzureRestMethod](https://github.com/eXpandFramework/XpandPwsh/wiki/Invoke-AzureRestMethod)|Invokes Azure DevOps REST API|
|[Invoke-PaketAdd](https://github.com/eXpandFramework/XpandPwsh/wiki/Invoke-PaketAdd)|Adds a package with Paket.|
|[Invoke-PaketClearCache](https://github.com/eXpandFramework/XpandPwsh/wiki/Invoke-PaketClearCache)|Clears all Paket caches for a repository.|
|[Invoke-PaketConvertFromNuget](https://github.com/eXpandFramework/XpandPwsh/wiki/Invoke-PaketConvertFromNuget)|Converts all projects under a folder to Paket usage instead of Nuget.|
|[Invoke-PaketFindVersions](https://github.com/eXpandFramework/XpandPwsh/wiki/Invoke-PaketFindVersions)|Search for Paket dependency Versions.|
|[Invoke-PaketInit](https://github.com/eXpandFramework/XpandPwsh/wiki/Invoke-PaketInit)|Create an empty paket.dependencies file in the current working directory.|
|[Invoke-PaketInstall](https://github.com/eXpandFramework/XpandPwsh/wiki/Invoke-PaketInstall)|Compute Paket dependency graph, download dependencies and update projects.|
|[Invoke-PaketRemove](https://github.com/eXpandFramework/XpandPwsh/wiki/Invoke-PaketRemove)|Remove a Paket dependency.|
|[Invoke-PaketRestore](https://github.com/eXpandFramework/XpandPwsh/wiki/Invoke-PaketRestore)|Download the Paket computed dependency graph.|
|[Invoke-PaketShowInstalled](https://github.com/eXpandFramework/XpandPwsh/wiki/Invoke-PaketShowInstalled)|Show Paket installed top-level packages.|
|[Invoke-PaketSimplify](https://github.com/eXpandFramework/XpandPwsh/wiki/Invoke-PaketSimplify)|Simplify declared dependencies by removing transitive dependencies.|
|[Invoke-PaketUpdate](https://github.com/eXpandFramework/XpandPwsh/wiki/Invoke-PaketUpdate)|Update Paket dependencies to their latest version.|
|[Invoke-Parallel](https://github.com/eXpandFramework/XpandPwsh/wiki/Invoke-Parallel)|Invokes tasks in parallel.|
|[Invoke-Script](https://github.com/eXpandFramework/XpandPwsh/wiki/Invoke-Script)|Invokes a Powershell script with retry options.|
|[Merge-HashTables](https://github.com/eXpandFramework/XpandPwsh/wiki/Merge-HashTables)|Merge HashTables.|
|[Mount-Assembly](https://github.com/eXpandFramework/XpandPwsh/wiki/Mount-Assembly)|Loads a .NET/.NETCore assembly into the AppDomain.|
|[Move-PaketSource](https://github.com/eXpandFramework/XpandPwsh/wiki/Move-PaketSource)|Replaces a Paket source in a paket.dependecy file.|
|[New-Assembly](https://github.com/eXpandFramework/XpandPwsh/wiki/New-Assembly)|Creates a new assembly.|
|[New-AssemblyResolver](https://github.com/eXpandFramework/XpandPwsh/wiki/New-AssemblyResolver)|Creates a Mono.Cecil Assembly Resolver.|
|[New-Command](https://github.com/eXpandFramework/XpandPwsh/wiki/New-Command)|Uses an external processs to execute a command and captures the output.|
|[New-GacAssemblyInstallReference](https://github.com/eXpandFramework/XpandPwsh/wiki/New-GacAssemblyInstallReference)|{{ Fill in the Synopsis }}|
|[New-GenericObject](https://github.com/eXpandFramework/XpandPwsh/wiki/New-GenericObject)|Create .Net Generic Objects.|
|[New-GitHubComment](https://github.com/eXpandFramework/XpandPwsh/wiki/New-GitHubComment)|Post a comment to a GitHub issue|
|[New-GithubReleaseNotes](https://github.com/eXpandFramework/XpandPwsh/wiki/New-GithubReleaseNotes)|Generates GitHub Release notes.|
|[New-GithubReleaseNotesTemplate](https://github.com/eXpandFramework/XpandPwsh/wiki/New-GithubReleaseNotesTemplate)|{{ Fill in the Synopsis }}|
|[New-MacAddress](https://github.com/eXpandFramework/XpandPwsh/wiki/New-MacAddress)|Generates a new MacAddress.|
|[New-TwitterContext](https://github.com/eXpandFramework/XpandPwsh/wiki/New-TwitterContext)|{{ Fill in the Synopsis }}|
|[New-TwitterFavorite](https://github.com/eXpandFramework/XpandPwsh/wiki/New-TwitterFavorite)|{{ Fill in the Synopsis }}|
|[New-XAFProject](https://github.com/eXpandFramework/XpandPwsh/wiki/New-XAFProject)|Creates a new XAF MSBuild project/solution In SDK format.|
|[Out-ConditionalColor](https://github.com/eXpandFramework/XpandPwsh/wiki/Out-ConditionalColor)|Display colorized pipelined output.|
|[Out-Variable](https://github.com/eXpandFramework/XpandPwsh/wiki/Out-Variable)|Output a variable name and value into the verbose stream.|
|[Out-Verbose](https://github.com/eXpandFramework/XpandPwsh/wiki/Out-Verbose)|Colored verbose stream output.|
|[Pop-GitSSH](https://github.com/eXpandFramework/XpandPwsh/wiki/Pop-GitSSH)|Pull from a Git repository using SSH.|
|[Pop-XafPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/Pop-XafPackage)|Download all XAF packages from a package source.|
|[Pop-XpandPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/Pop-XpandPackage)|Download all Xpand packages from a package source.|
|[Publish-AssemblyToGac](https://github.com/eXpandFramework/XpandPwsh/wiki/Publish-AssemblyToGac)|Publish assemblies to Gac.|
|[Publish-GitHubRelease](https://github.com/eXpandFramework/XpandPwsh/wiki/Publish-GitHubRelease)|Publish a release for a Github repository.|
|[Publish-NugetPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/Publish-NugetPackage)|Publishes a NuGet package.|
|[Push-Git](https://github.com/eXpandFramework/XpandPwsh/wiki/Push-Git)|Push a Git repository to a remote using a token.|
|[Push-GitSSH](https://github.com/eXpandFramework/XpandPwsh/wiki/Push-GitSSH)|Push to a remote a Git repository using SSH.|
|[Push-TwitterMedia](https://github.com/eXpandFramework/XpandPwsh/wiki/Push-TwitterMedia)|{{ Fill in the Synopsis }}|
|[Read-AssemblyDefinition](https://github.com/eXpandFramework/XpandPwsh/wiki/Read-AssemblyDefinition)|Reads Assembly using Mono.Cecil which does not load it into the AppDomain.|
|[Read-MSBuildProject](https://github.com/eXpandFramework/XpandPwsh/wiki/Read-MSBuildProject)|Reads an MSBuild project using the MSBuild.Evaluation.Framework.|
|[Remove-AzBuild](https://github.com/eXpandFramework/XpandPwsh/wiki/Remove-AzBuild)|Deletes an AzureDevOps build.|
|[Remove-AzBuildInProgress](https://github.com/eXpandFramework/XpandPwsh/wiki/Remove-AzBuildInProgress)|Remove AzureDevOps in-progress builds.|
|[Remove-BlankLines](https://github.com/eXpandFramework/XpandPwsh/wiki/Remove-BlankLines)|Removes blank lines from a files|
|[Remove-DefaultValueKeys](https://github.com/eXpandFramework/XpandPwsh/wiki/Remove-DefaultValueKeys)|Removes hastable keys with default values.|
|[Remove-GacAssembly](https://github.com/eXpandFramework/XpandPwsh/wiki/Remove-GacAssembly)|Removes GAC Assemblies.|
|[Remove-GitHubRelease](https://github.com/eXpandFramework/XpandPwsh/wiki/Remove-GitHubRelease)|Remove a Github release.|
|[Remove-NugetImportsTargets](https://github.com/eXpandFramework/XpandPwsh/wiki/Remove-NugetImportsTargets)|Removes all Nuget Import targets from a project.|
|[Remove-PackageReference](https://github.com/eXpandFramework/XpandPwsh/wiki/Remove-PackageReference)|Removes project package references.|
|[Remove-ProjectInvalidItems](https://github.com/eXpandFramework/XpandPwsh/wiki/Remove-ProjectInvalidItems)|Evaluates the MSBuild using Microsoft.Build.Framework and removes invalid items (Imports, Analyzers etc).|
|[Remove-ProjectLicenseFile](https://github.com/eXpandFramework/XpandPwsh/wiki/Remove-ProjectLicenseFile)|Removes licx files from a VS project.|
|[Remove-ProjectReferences](https://github.com/eXpandFramework/XpandPwsh/wiki/Remove-ProjectReferences)|Removes MSBuild project references.|
|[Remove-VersionConverterFlags](https://github.com/eXpandFramework/XpandPwsh/wiki/Remove-VersionConverterFlags)|Removes Xpand.VersionConverter flags so to repatch the assemblies.|
|[Resolve-AssemblyDependencies](https://github.com/eXpandFramework/XpandPwsh/wiki/Resolve-AssemblyDependencies)|Resolve all referenced assemblies for a given assembly, reclusively.|
|[Restore-GitFile](https://github.com/eXpandFramework/XpandPwsh/wiki/Restore-GitFile)|Resets git file changes.|
|[Restore-ProjectReference](https://github.com/eXpandFramework/XpandPwsh/wiki/Restore-ProjectReference)|Replace Nuget packages with project references.|
|[Save-Xml](https://github.com/eXpandFramework/XpandPwsh/wiki/Save-Xml)|Saves an Xml Document.|
|[Send-Retweet](https://github.com/eXpandFramework/XpandPwsh/wiki/Send-Retweet)|{{ Fill in the Synopsis }}|
|[Send-Tweet](https://github.com/eXpandFramework/XpandPwsh/wiki/Send-Tweet)|{{ Fill in the Synopsis }}|
|[Send-TweetDirectMessage](https://github.com/eXpandFramework/XpandPwsh/wiki/Send-TweetDirectMessage)|{{ Fill in the Synopsis }}|
|[Set-NugetCentralizeManagement](https://github.com/eXpandFramework/XpandPwsh/wiki/Set-NugetCentralizeManagement)|{{ Fill in the Synopsis }}|
|[Set-ProjectRestoreLockedMode](https://github.com/eXpandFramework/XpandPwsh/wiki/Set-ProjectRestoreLockedMode)|{{ Fill in the Synopsis }}|
|[Set-VsoVariable](https://github.com/eXpandFramework/XpandPwsh/wiki/Set-VsoVariable)|Set an AzureDevOps variable.|
|[Start-Build](https://github.com/eXpandFramework/XpandPwsh/wiki/Start-Build)|Builds solutions and projects.|
|[Start-EasyTest](https://github.com/eXpandFramework/XpandPwsh/wiki/Start-EasyTest)|Execute DevExpress XAF EasyTests.|
|[Start-NugetRestore](https://github.com/eXpandFramework/XpandPwsh/wiki/Start-NugetRestore)|Restores the Nuget packages.|
|[Start-PipelineTasks](https://github.com/eXpandFramework/XpandPwsh/wiki/Start-PipelineTasks)|{{ Fill in the Synopsis }}|
|[Start-SelfElevate](https://github.com/eXpandFramework/XpandPwsh/wiki/Start-SelfElevate)|Elevates the current powershell session|
|[Start-SqlLocalDB](https://github.com/eXpandFramework/XpandPwsh/wiki/Start-SqlLocalDB)|Starts Sql-Server LocalDB.|
|[Start-XpandProjectConverter](https://github.com/eXpandFramework/XpandPwsh/wiki/Start-XpandProjectConverter)|Updates DevExpress version in all projects inside a folder, treats *.proj, *.config, *.aspx files.|
|[Submit-GitStage](https://github.com/eXpandFramework/XpandPwsh/wiki/Submit-GitStage)|Stage all Git unstaged files.|
|[Switch-DevExpress](https://github.com/eXpandFramework/XpandPwsh/wiki/Switch-DevExpress)|Switch csproj DevExpress references to Nuget packages|
|[Switch-ToPackageReference](https://github.com/eXpandFramework/XpandPwsh/wiki/Switch-ToPackageReference)|Replace MSBuild project references with Nuget package references.|
|[Test-AssemblyNameFullyQualified](https://github.com/eXpandFramework/XpandPwsh/wiki/Test-AssemblyNameFullyQualified)|{{ Fill in the Synopsis }}|
|[Test-AssemblyReference](https://github.com/eXpandFramework/XpandPwsh/wiki/Test-AssemblyReference)|Lists assemblies that do not match the VersionFilter.|
|[Test-AzDevops](https://github.com/eXpandFramework/XpandPwsh/wiki/Test-AzDevops)|Test if script is running on AzureDevOps environment.|
|[Test-ChocoInstalled](https://github.com/eXpandFramework/XpandPwsh/wiki/Test-ChocoInstalled)|{{ Fill in the Synopsis }}|
|[Test-GacAssemblyInstallReferenceCanBeUsed](https://github.com/eXpandFramework/XpandPwsh/wiki/Test-GacAssemblyInstallReferenceCanBeUsed)|{{ Fill in the Synopsis }}|
|[Test-ProjectSdk](https://github.com/eXpandFramework/XpandPwsh/wiki/Test-ProjectSdk)|Test is MSBuild project uses the SDK format.|
|[Test-Symbol](https://github.com/eXpandFramework/XpandPwsh/wiki/Test-Symbol)|Checks if the symbol is valid for a given assembly.|
|[Test-Version](https://github.com/eXpandFramework/XpandPwsh/wiki/Test-Version)|Test a string if it is a valid System.Version.|
|[Uninstall-AllModules](https://github.com/eXpandFramework/XpandPwsh/wiki/Uninstall-AllModules)|Uninstall all Powershell modules.|
|[UnInstall-DotnetCoreSdk](https://github.com/eXpandFramework/XpandPwsh/wiki/UnInstall-DotnetCoreSdk)|UnInstall a DotnetCoreSdk.|
|[Uninstall-ProjectAllPackages](https://github.com/eXpandFramework/XpandPwsh/wiki/Uninstall-ProjectAllPackages)|Uninstall all NuGet and their dependencies from a project.|
|[UnInstall-Xpand](https://github.com/eXpandFramework/XpandPwsh/wiki/UnInstall-Xpand)|Uninstall eXpandFramework project.|
|[Unprotect-SecretVariable](https://github.com/eXpandFramework/XpandPwsh/wiki/Unprotect-SecretVariable)|Displays a secret variable value.|
|[UnPublish-NugetPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/UnPublish-NugetPackage)|Unpublish Nuget packages from a source.|
|[Update-AppendTargetFrameworkToOutputPath](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-AppendTargetFrameworkToOutputPath)|Update MSBuild projects AppendTargetFrameworkToOutputPath property.|
|[Update-AssemblyInfo](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-AssemblyInfo)|Updates the AssemblyInfo.cs version|
|[Update-AssemblyInfoVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-AssemblyInfoVersion)|Updates the AssemblyInfo.cs version|
|[Update-AzBuild](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-AzBuild)|Update an AzureDevops build.|
|[Update-GenerateAssemblyInfo](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-GenerateAssemblyInfo)|{{ Fill in the Synopsis }}|
|[Update-GitHubIssue](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-GitHubIssue)|Update a GitHub issue.|
|[Update-HintPath](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-HintPath)|Update VS project HintPath.|
|[Update-NugetPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-NugetPackage)|Update VS project NuGet packages to their latest version found from all registered in the system sources.|
|[Update-NugetProjectVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-NugetProjectVersion)|Update the version found in AssemblyInfo.cs looking in Git history for any midification since the last tag.|
|[Update-Nuspec](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-Nuspec)|{{ Fill in the Synopsis }}|
|[Update-OutputPath](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-OutputPath)|Updates VS project output path.|
|[Update-ProjectAutoGenerateBindingRedirects](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-ProjectAutoGenerateBindingRedirects)|Enables AutoGenerateBindingRedirects for a VS project.|
|[Update-ProjectCopyRight](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-ProjectCopyRight)|{{ Fill in the Synopsis }}|
|[Update-ProjectDebugSymbols](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-ProjectDebugSymbols)|Enable Debug Symbols for a VS Project.|
|[Update-ProjectLanguageVersion](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-ProjectLanguageVersion)|Update Project language version to `Latest`|
|[Update-ProjectNoWarn](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-ProjectNoWarn)|{{ Fill in the Synopsis }}|
|[Update-ProjectPackage](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-ProjectPackage)|Calls the `Update-NugetPackage` cmdlet from inside VS Package Manager Console|
|[Update-ProjectProperty](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-ProjectProperty)|Update a VS project property.|
|[Update-ProjectSign](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-ProjectSign)|Signs a VS project.|
|[Update-ProjectTargetFramework](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-ProjectTargetFramework)|Update the Target Framework in a MSBuild project.|
|[Update-Symbols](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-Symbols)|Index symbols to local or remote locations.|
|[Update-Version](https://github.com/eXpandFramework/XpandPwsh/wiki/Update-Version)|Update version parts.|
|[Use-MonoCecil](https://github.com/eXpandFramework/XpandPwsh/wiki/Use-MonoCecil)|Loads the Mono.Cecil assembly.|
|[Use-MSBuildFramework](https://github.com/eXpandFramework/XpandPwsh/wiki/Use-MSBuildFramework)|{{ Fill in the Synopsis }}|
|[Use-NugetAssembly](https://github.com/eXpandFramework/XpandPwsh/wiki/Use-NugetAssembly)|{{ Fill in the Synopsis }}|
|[Use-NugetConfig](https://github.com/eXpandFramework/XpandPwsh/wiki/Use-NugetConfig)|{{ Fill in the Synopsis }}|
|[Use-Object](https://github.com/eXpandFramework/XpandPwsh/wiki/Use-Object)|Disposes a disposable object, same as c# using keyword.|
|[Wait-Task](https://github.com/eXpandFramework/XpandPwsh/wiki/Wait-Task)|Wait for a task to complete. Similar to c# await keyword.|
|[Write-HostFormatted](https://github.com/eXpandFramework/XpandPwsh/wiki/Write-HostFormatted)|Text formatting.|
|[Write-PSCmdLetBegin](https://github.com/eXpandFramework/XpandPwsh/wiki/Write-PSCmdLetBegin)|{{ Fill in the Synopsis }}|
|[Write-Verbose](https://github.com/eXpandFramework/XpandPwsh/wiki/Write-Verbose)||
 
