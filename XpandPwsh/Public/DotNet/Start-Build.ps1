function Start-Build {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#msbuild"))]
    [alias("sxb")]
    param (
        [parameter(ValueFromPipeline)]
        [string]$Path=(@(Get-ChildItem "*.sln" )+@(Get-ChildItem "*.*proj" )|select-object -first 1).FullName,
        [ArgumentCompleter( {
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
            $p=$fakeBoundParameter.Path
            if (!$p){
                $p=(@(Get-ChildItem "*.sln" )+@(Get-ChildItem "*.*proj" )|select-object -first 1).FullName
            }
            
            ((Read-MSBuildSolutionFile $p).SolutionConfigurations|sort-object ConfigurationName -Unique).ConfigurationName|where-object {$_ -like "*$wordToComplete*"}
        })]
        [string]$Configuration="Debug",
        [ValidateSet("quiet","minimal","normal","detailed","diagnostic")]
        [string]$Verbosity="minimal",
        [switch]$WarnAsError,
        [string]$BinaryLogPath,
        [switch]$NoRestore,
        [int]$MaxCpuCount=([System.Environment]::ProcessorCount),
        [System.IO.FileInfo]$PublishProfile,
        [string[]]$PropertyValue,
        [string[]]$PackageSource
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        $item=Get-Item $Path
        $project=$item
        if ($item -is [System.IO.DirectoryInfo]){
            Push-Location $item.FullName
            $project=@(Get-ChildItem "*.sln" )+@(Get-ChildItem "*.*proj" )
            Pop-Location
        }
        Invoke-Script{
            $project|ForEach-Object{
                $currentProject = $_.FullName
                
                # Determine build engine
                $cliSupported = Test-ProjectSdk -InputObject $currentProject
                
                $cmd = $null
                $p = @()

                if ($cliSupported) {
                    # --- DOTNET CLI ARGUMENTS ---
                    $cmd = "dotnet"
                    $p += "build", $currentProject
                    
                    # CLI specific flags
                    $p += "-v", $Verbosity
                    if ($Configuration) { $p += "-c", $Configuration }
                    if ($NoRestore)     { $p += "--no-restore" }
                    
                    # Pass-through MSBuild switches (dotnet accepts /p: /m: etc)
                    if ($MaxCpuCount)   { $p += "/m:$MaxCpuCount" }
                    if ($WarnAsError)   { $p += "/warnaserror" }
                }
                else {
                    # --- MSBUILD.EXE ARGUMENTS ---
                    $cmd = (Get-MsBuildPath)
                    $p += $currentProject
                    $p += "/t:Build"
                    
                    # MSBuild specific flags
                    $p += "/v:$Verbosity"
                    if ($Configuration) { $p += "/p:Configuration=$Configuration" }
                    
                    # MSBuild does not restore by default in older versions. 
                    # We add /restore unless NoRestore is requested.
                    if (-not $NoRestore){ $p += "/restore" }
                    
                    if ($MaxCpuCount)   { $p += "/m:$MaxCpuCount" }
                    if ($WarnAsError)   { $p += "/warnaserror" }
                }

                # --- COMMON ARGUMENTS (Properties & Logs) ---
                if ($BinaryLogPath) { 
                    $p += "/bl:$BinaryLogPath" 
                }
                
                # Publish properties
                if ($PublishProfile){
                    $p += "/p:DeployOnBuild=true", "/p:PublishProfile=$($PublishProfile.Name)"
                }
                
                # Custom Properties
                if ($PropertyValue){
                    $p += $PropertyValue | ForEach-Object { "/p:$_" }
                }

                # --- EXECUTION ---
                Write-Verbose "Building with: $cmd"
                
                if ($PackageSource){
                    Use-NugetConfig -Sources $PackageSource -ScriptBlock {
                        & $cmd @p
                    }
                }
                else{
                    & $cmd @p
                }
            }
        }
    }
    end {
        
    }
}