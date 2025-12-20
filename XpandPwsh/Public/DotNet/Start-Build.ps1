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
# MODIFICATION: START
                # Transition to dotnet CLI syntax
                $p = @("build", $_.FullName)
                
                # Standard dotnet flags
                $p += "-v", $Verbosity
                
                if ($Configuration){
                    $p += "-c", $Configuration
                }

                # dotnet restores by default; only explicitly disable it
                if ($NoRestore){
                    $p += "--no-restore"
                }

                # MSBuild pass-throughs
                if ($MaxCpuCount){
                    $p += "-m:$MaxCpuCount"
                }
                if ($WarnAsError){
                    $p += "-warnaserror"
                }
                if ($BinaryLogPath){
                    $p += "/bl:$BinaryLogPath"
                }
                
                # Publish properties (Legacy WebDeploy support via build)
                if ($PublishProfile){
                    $p += "/p:DeployOnBuild=true", "/p:PublishProfile=$($PublishProfile.Name)"
                }
                if ($PropertyValue){
                    $p += $PropertyValue | ForEach-Object { "/p:$_" }
                }

                # Execution
                if ($PackageSource){
                    Use-NugetConfig -Sources $PackageSource -ScriptBlock {
                        & dotnet @p
                    }
                }
                else{
                    & dotnet @p
                }
            }
        }
    }
    end {
        
    }
}