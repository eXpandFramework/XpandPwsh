function Invoke-Script {
    [CmdletBinding()]
    Param(
        [Parameter(Position=0, Mandatory=$true)]
        [scriptblock]$Script,

        [Parameter(Position=1, Mandatory=$false)]
        [int]$Maximum = 1,
        [int]$RetryInterval=1
    )

    Begin {
        $cnt = 0
    }

    Process {
        do {
            $cnt++
            try {
                & $Script
                Approve-LastExitCode
                return
            } catch {
                Write-Warning $_
                Write-Error "Error: Retrying in $RetryInterval seconds, attempt$cnt out of $Maximum" -ErrorAction Continue
                [System.Threading.Thread]::Sleep([System.TimeSpan]::FromSeconds($RetryInterval))

                
            }
        } while ($cnt -lt $Maximum)
        exit 1
    }
}
