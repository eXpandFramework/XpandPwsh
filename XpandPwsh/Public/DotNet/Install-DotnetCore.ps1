function Install-DotnetCore {
    <#
.SYNOPSIS
    Installs dotnet cli
.DESCRIPTION
    Installs dotnet cli. If dotnet installation already exists in the given directory
    it will update it only if the requested version differs from the one already installed.
.PARAMETER Channel
    Default: LTS
    Download from the Channel specified. Possible values:
    - Current - most current release
    - LTS - most current supported release
    - 2-part version in a format A.B - represents a specific release
          examples: 2.0, 1.0
    - Branch name
          examples: release/2.0.0, Master
    Note: The version parameter overrides the channel parameter.
.PARAMETER Version
    Default: latest
    Represents a build version on specific channel. Possible values:
    - latest - most latest build on specific channel
    - coherent - most latest coherent build on specific channel
          coherent applies only to SDK downloads
    - 3-part version in a format A.B.C - represents specific version of build
          examples: 2.0.0-preview2-006120, 1.1.0
.PARAMETER InstallDir
    Default: %LocalAppData%\Microsoft\dotnet
    Path to where to install dotnet. Note that binaries will be placed directly in a given directory.
.PARAMETER Architecture
    Default: <auto> - this value represents currently running OS architecture
    Architecture of dotnet binaries to be installed.
    Possible values are: <auto>, amd64, x64, x86, arm64, arm
.PARAMETER SharedRuntime
    This parameter is obsolete and may be removed in a future version of this script.
    The recommended alternative is '-Runtime dotnet'.
    Installs just the shared runtime bits, not the entire SDK.
.PARAMETER Runtime
    Installs just a shared runtime, not the entire SDK.
    Possible values:
        - dotnet     - the Microsoft.NETCore.App shared runtime
        - aspnetcore - the Microsoft.AspNetCore.App shared runtime
        - windowsdesktop - the Microsoft.WindowsDesktop.App shared runtime
.PARAMETER DryRun
    If set it will not perform installation but instead display what command line to use to consistently install
    currently requested version of dotnet cli. In example if you specify version 'latest' it will display a link
    with specific version so that this command can be used deterministicly in a build script.
    It also displays binaries location if you prefer to install or download it yourself.
.PARAMETER NoPath
    By default this script will set environment variable PATH for the current process to the binaries folder inside installation folder.
    If set it will display binaries location but not set any environment variable.
.PARAMETER Verbose
    Displays diagnostics information.
.PARAMETER AzureFeed
    Default: https://dotnetcli.azureedge.net/dotnet
    This parameter typically is not changed by the user.
    It allows changing the URL for the Azure feed used by this installer.
.PARAMETER UncachedFeed
    This parameter typically is not changed by the user.
    It allows changing the URL for the Uncached feed used by this installer.
.PARAMETER FeedCredential
    Used as a query string to append to the Azure feed.
    It allows changing the URL to use non-public blob storage accounts.
.PARAMETER ProxyAddress
    If set, the installer will use the proxy when making web requests
.PARAMETER ProxyUseDefaultCredentials
    Default: false
    Use default credentials, when using proxy address.
.PARAMETER SkipNonVersionedFiles
    Default: false
    Skips installing non-versioned files if they already exist, such as dotnet.exe.
.PARAMETER NoCdn
    Disable downloading from the Azure CDN, and use the uncached feed directly.
.PARAMETER JSonFile
    Determines the SDK version from a user specified global.json file
    Note: global.json must have a value for 'SDK:Version'
#>
    [cmdletbinding()]
    [CmdLetTag(("#dotnet","#dotnetcore"))]
    param(
        [string]$Channel = "LTS",
        [string]$Version = "Latest",
        [string]$JSonFile,
        [string]$InstallDir = "<auto>",
        [string]$Architecture = "<auto>",
        [ValidateSet("dotnet", "aspnetcore", "windowsdesktop", IgnoreCase = $false)]
        [parameter(Mandatory)]
        [string]$Runtime,
        [Obsolete("This parameter may be removed in a future version of this script. The recommended alternative is '-Runtime dotnet'.")]
        [switch]$SharedRuntime,
        [switch]$DryRun,
        [switch]$NoPath,
        [string]$AzureFeed = "https://dotnetcli.azureedge.net/dotnet",
        [string]$UncachedFeed = "https://dotnetcli.blob.core.windows.net/dotnet",
        [string]$FeedCredential,
        [string]$ProxyAddress,
        [switch]$ProxyUseDefaultCredentials,
        [switch]$SkipNonVersionedFiles,
        [switch]$NoCdn
    )
    
    begin {
        
    }
    
    process {
        $a = @{
            Channel = $Channel
            Version=$Version
            JsonFile=$JsonFile
            InstallDir=$InstallDir
            Architecture=$Architecture
            Runtime=$Runtime
            SharedRuntime=$SharedRuntime
            DryRun=$DryRun
            AzureFeed=$AzureFeed
            UncachedFeed=$UncachedFeed
            ProxyAddress=$ProxyAddress
            ProxyUseDefaultCredentials=$ProxyUseDefaultCredentials
            SkipNonVersionedFiles=$SkipNonVersionedFiles
            NoCdn=$NoCdn


        }   
        & "$PSScriptRoot\..\..\private\dotnet-install.ps1" @a
    }
    
    end {
        
    }
}