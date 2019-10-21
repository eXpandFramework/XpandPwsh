function Clear-NugetCache {
    [CmdletBinding()]
    param (
        [ValidateSet("XpandPackages")]
        $Filter
    )
    
    begin {
    }
    
    process {
        if ($Filter) {
            $path = (Get-NugetInstallationFolder GlobalPackagesFolder)
            $folders=Get-ChildItem $path 
            $folders|Where-Object{$_.BaseName -like "Xpand*" -or $_.BaseName -like "eXpand*" -and $_.BaseName -notlike "*VersionConverter"}|Remove-Item -Recurse -Force 
        }
        else {
            & (Get-NugetPath) locals all -clear
        }
        
    }
    
    end {
    }
}