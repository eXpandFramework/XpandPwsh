function New-Command{
    param($commandTitle, $commandPath, $commandArguments,$workingDir)
    Try {
        $pinfo = New-Object System.Diagnostics.ProcessStartInfo
        $pinfo.FileName = $commandPath
        $pinfo.RedirectStandardError = $true
        if ($workingDir){
            $pinfo.WorkingDirectory=$workingDir
        }
        $pinfo.RedirectStandardOutput = $true
        $pinfo.UseShellExecute = $false
        $pinfo.Arguments = $commandArguments
        $p = New-Object System.Diagnostics.Process
        $p.StartInfo = $pinfo
        $p.Start() | Out-Null
        [pscustomobject]@{
            commandTitle = $commandTitle
            stdout = $p.StandardOutput.ReadToEnd()
            stderr = $p.StandardError.ReadToEnd()
            ExitCode = $p.ExitCode
        }
        $p.WaitForExit()
    }
    Catch {
        [pscustomobject]@{
            commandTitle = $commandTitle
            stderr = $_.Exception.Message
            ExitCode = 1
        }
    }
}