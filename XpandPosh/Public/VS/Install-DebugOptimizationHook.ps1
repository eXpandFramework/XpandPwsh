function Install-DebugOptimizationHook {
    [CmdletBinding()]
    param (
        [switch]$Disable
    )
    
    begin {
    }
    
    process {
        Push-Location 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\'
        if (!$Disable) { 
            if (Test-Path ".\devenv.exe"){
                "hook already exists"
            }
            else{
                $startVs=[System.IO.Path]::GetFullPath("$PSScriptRoot\..\..\Private\Start-VS.ps1")
                New-Item -path . -name devenv.exe| New-ItemProperty -Name Debugger -Value "powershell.exe  -windowstyle hidden -File $startVs"|Out-Null
                "hook installed for $startVs"
            }
            "Use the Disable switch to uninstall"
        }
        else{
            if (Test-Path ".\devenv.exe"){
                Remove-Item ".\devenv.exe"
                "hook removed"
            }
            else{
                "hook not found"
            }
        }
        Pop-Location
    }
    
    end {
    }
}