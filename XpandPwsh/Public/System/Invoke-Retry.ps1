function Invoke-Retry {
    [CmdletBinding()]
    Param(
        [Parameter(Position=0, Mandatory=$true)]
        [scriptblock]$ScriptBlock,

        [Parameter(Position=1, Mandatory=$false)]
        [int]$Maximum = 5,
        [int]$RetryInterval=1
    )

    Begin {
        $cnt = 0
    }

    Process {
        do {
            $cnt++
            try {
                $ScriptBlock.Invoke()
                return
            } catch {
                [System.Threading.Thread]::Sleep([System.TimeSpan]::FromSeconds($RetryInterval))
                Write-Error $_.Exception.InnerException.Message -ErrorAction Continue
            }
        } while ($cnt -lt $Maximum)
        throw 'Execution failed.'
    }
}