
function Invoke-PaketShowInstalled {
    [CmdletBinding()]
    param (
        [parameter(ParameterSetName="Project")]
        [string]$Project,
        [switch]$OnlyDirect,
        [string]$Path="."
    )
    
    begin {
        if ($PSCmdlet.ParameterSetName -eq "Project"){
            $Path =$Project
        }
    }
    
    process {
        $paketExe = (Get-PaketDependenciesPath $Path)
        if ($paketExe) {
            $xtraArgs = @( "--silent");
            if (!$OnlyDirect) {
                $xtraArgs += "--all"
            }
            Set-Location (Get-Item $paketExe).DirectoryName
            if ($Project){
                $pakets=dotnet paket show-installed-packages --project $Project @xtraArgs
            }
            else{
                $pakets=dotnet paket show-installed-packages @xtraArgs
            }
            $pakets| ForEach-Object {
                $parts = $_.split(" ")
                [PSCustomObject]@{
                    Group   = $parts[0]
                    Id      = $parts[1]
                    Version = $parts[3]
                }
            }
            # Invoke-PaketCommand {
                
            # }
            # Invoke-Expression "$paketExe show-installed-packages $([string]::Join(' ',$xtraArgs))" | ForEach-Object {
            #     $parts = $_.split(" ")
            #     [PSCustomObject]@{
            #         Group   = $parts[0]
            #         Id      = $parts[1]
            #         Version = $parts[3]
            #     }
            # }
            # Approve-LastExitCode
        }
    }
    
    end {
        
    }
}

function Invoke-PaketCommand {
    param(
        [Parameter(Mandatory)]
        [scriptblock]$Script
    )
    & $Script
    Approve-LastExitCode
}