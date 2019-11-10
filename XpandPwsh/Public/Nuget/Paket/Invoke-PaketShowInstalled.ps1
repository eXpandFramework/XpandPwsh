
function Invoke-PaketShowInstalled {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string]$Project,
        [switch]$OnlyDirect
    )
    
    begin {
        
    }
    
    process {
        $paketExe = (Get-PaketPath $Project)
        if ($paketExe) {
            $xtraArgs = @("--project `"$Project`"", "--silent");
            if (!$OnlyDirect) {
                $xtraArgs += "--all"
            }
            & $paketExe show-installed-packages --project $Project --silent --all| ForEach-Object {
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