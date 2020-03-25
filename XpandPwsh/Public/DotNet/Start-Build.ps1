function Start-Build {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#msbuild"))]
    [alias("sxb")]
    param (
        [parameter(ValueFromPipeline)]
        [string]$Path=".",
        [string]$Configuration,
        [ValidateSet("quiet","minimal","normal","detailed","diagnostic")]
        [string]$Verbosity="minimal",
        [switch]$WarnAsError,
        [string]$BinaryLogPath,
        [switch]$NoRestore,
        [int]$MaxCpuCount=([System.Environment]::ProcessorCount)
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
                $p=@($_.FullName,"-verbosity:$Verbosity","-maxCpuCount:$MaxCpuCount")
                if (!$NoRestore){
                    $p+="-Restore"
                }
                if ($WarnAsError){
                    $p+="-warnAsError"
                }
                if ($BinaryLogPath){
                    $p+="/bl:$BinaryLogPath"
                }
                if ($Configuration){
                    $p+="/p:Configuration=$Configuration"
                }
                & (Get-MsBuildPath) @p
            }
        }
    }
    end {
        
    }
}