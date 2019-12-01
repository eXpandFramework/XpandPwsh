function Uninstall-AllModules {
    param(
      [Parameter(Mandatory=$true)]
      [string]$TargetModule,
  
      [Parameter(Mandatory=$true)]
      [string]$Version,
  
      [switch]$Force,
  
      [switch]$WhatIf
    )
    
    $AllModules = @()
    
    'Creating list of dependencies...'
    $target = Find-Module $TargetModule -RequiredVersion $version
    $target.Dependencies | ForEach-Object {
      if ($_.PSObject.Properties.Name -contains 'requiredVersion') {
        $AllModules += New-Object -TypeName psobject -Property @{name=$_.name; version=$_.requiredVersion}
      }
      else { # Assume minimum version
        # Minimum version actually reports the installed dependency
        # which is used, not the actual "minimum dependency." Check to
        # see if the requested version was installed as a dependency earlier.
        $candidate = Get-InstalledModule $_.name -RequiredVersion $version -ErrorAction Ignore
        if ($candidate) {
          $AllModules += New-Object -TypeName psobject -Property @{name=$_.name; version=$version}
        }
        else {
          $availableModules = Get-InstalledModule $_.name -AllVersions
          Write-Warning ("Could not find uninstall candidate for {0}:{1} - module may require manual uninstall. Available versions are: {2}" -f $_.name,$version,($availableModules.Version -join ', '))
        }
      }
    }
    $AllModules += New-Object -TypeName psobject -Property @{name=$TargetModule; version=$Version}
  
    foreach ($module in $AllModules) {
      Write-Host ('Uninstalling {0} version {1}...' -f $module.name,$module.version)
      try {
        Uninstall-Module -Name $module.name -RequiredVersion $module.version -Force:$Force -ErrorAction Stop -WhatIf:$WhatIf
      } catch {
        Write-Host ("`t" + $_.Exception.Message)
      }
    }
  }