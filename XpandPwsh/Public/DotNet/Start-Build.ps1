function Start-Build {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#msbuild"))]
    param (
        [parameter(ValueFromPipeline)]
        [string]$Path=".",
        [ValidateSet("quiet","minimal","normal","detailed","diagnostic")]
        [string]$Verbosity="detailed",
        [switch]$WarnAsError,
        [string]$BinaryLogPath,
        [switch]$Restore,
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
                if ($Restore){
                    $p+="-Restore"
                }
                if ($WarnAsError){
                    $p+="-warnAsError"
                }
                if ($BinaryLogPath){
                    $p+="/bl:$BinaryLogPath"
                }
                & (Get-MsBuildPath) @p
            }
        }
    }
    end {
        
    }
}