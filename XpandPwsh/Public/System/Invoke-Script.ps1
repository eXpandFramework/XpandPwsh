function Invoke-Script {
    [CmdletBinding()]
    [CmdLetTag()]
    Param(
        [Parameter(Position=0, Mandatory=$true)]
        [scriptblock]$Script,

        [Parameter(Position=1, Mandatory=$false)]
        [int]$Maximum = 1,
        [int]$RetryInterval=1,
        [string]$retryTriggerErrorPattern = $null
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
                if ($retryTriggerErrorPattern -ne $null) {
                    $isMatch = [regex]::IsMatch($_.Exception.Message, $retryTriggerErrorPattern)
    
                    if ($isMatch -eq $false) {
                        throw $_
                    }
                }
                if (!($cnt -lt $Maximum )) {
                    Write-HostFormatted "Exception:" -ForegroundColor Red -Section
                    Write-HostFormatted $_ -ForegroundColor Red
                    $_
                    Write-HostFormatted "StackTrace:" -ForegroundColor Yellow -Section
                    $_.ScriptStackTrace
                    throw 
                }
    
                Write-Warning $_
                Write-Error "Error: Retrying in $RetryInterval seconds, attempt$cnt out of $Maximum" -ErrorAction Continue
                [System.Threading.Thread]::Sleep([System.TimeSpan]::FromSeconds($RetryInterval))

                
            }
        } while ($cnt -lt $Maximum)
        throw
        
    }
}
