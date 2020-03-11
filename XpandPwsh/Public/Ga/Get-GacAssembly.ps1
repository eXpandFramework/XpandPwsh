function Get-GacAssembly {
    [CmdletBinding(DefaultParameterSetName = 'PartsSet')]
    [OutputType('System.Reflection.AssemblyName')]
    param  (
        [Parameter(Position = 0, ParameterSetName = 'PartsSet')]
        [ValidateNotNullOrEmpty()] 
        [string[]] $Name,

        [Parameter(Position = 1, ParameterSetName = 'PartsSet')]
        [ValidateNotNullOrEmpty()]
        [string[]] $Version,

        [Parameter(Position = 2, ParameterSetName = 'PartsSet')]
        [ValidateNotNullOrEmpty()]
        [string[]] $Culture,

        [Parameter(Position = 3, ParameterSetName = 'PartsSet')]
        [ValidateNotNullOrEmpty()]
        [string[]] $PublicKeyToken,

        [Parameter(Position = 4, ParameterSetName = 'PartsSet')]
        [ValidateNotNullOrEmpty()]
        [System.Reflection.ProcessorArchitecture[]] $ProcessorArchitecture,

        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'AssemblyNameSet')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-AssemblyNameFullyQualified $_ } )]
        [System.Reflection.AssemblyName[]] $AssemblyName
    )
    begin{
        $converter={
            param($stdOut)
            $stdout.Split("`r`n")|Where-Object{$_}|Select-Object -Skip 2|ForEach-Object{
                $parts=$_.Trim().Split(' ')|Where-Object{$_}
                [PSCustomObject]@{
                    Name = $parts|Select-Object -Last 1
                    Version = $parts|Select-Object -First 1
                }
            }
        }
    }
    process {
        if ($PSVersionTable.PSEdition -eq "Core"){
            & $converter (New-Command "Gac Assemblies" -commandPath "c:\windows\syswow64\WindowsPowerShell\v1.0\powershell.exe" -commandArguments "-command `"& {&'Get-GacAssembly' }`"").stdout
            return
        }
        if ($PsCmdlet.ParameterSetName -eq 'AssemblyNameSet') {
            $fullNames = @()
            foreach ($assmName in $AssemblyName) {
                $fullNames += $assmName.FullyQualifiedName
            }

            foreach ($assembly in [XpandPwsh.Cmdlets.Gac.GlobalAssemblyCache]::GetAssemblies()) {
                $fullyQualifiedAssemblyName = $assembly.FullyQualifiedName
                foreach ($fullName in $fullNames) {
                    if ($fullyQualifiedAssemblyName -eq $fullName) {
                        $assembly
                        break
                    } 
                }
            }
        }
        else {
            foreach ($assembly in [XpandPwsh.Cmdlets.Gac.GlobalAssemblyCache]::GetAssemblies()) {
                $hit = $false
                foreach ($n in $Name) {
                    if ($assembly.Name -like $n) {
                        $hit = $true
                        break
                    }
                }
                if ($Name -and -not $hit) {
                    continue
                }

                $hit = $false
                foreach ($v in $Version) {
                    if ($assembly.Version -like $v) {
                        $hit = $true
                        break
                    }
                }
                if ($Version -and -not $hit) {
                    continue
                }

                $hit = $false
                foreach ($c in $Culture) {
                    if ($c -eq 'neutral' -and $assembly.CultureInfo.Equals([System.Globalization.CultureInfo]::InvariantCulture)) {
                        $hit = $true
                        break
                    }
                    if ($c -ne 'neutral' -and $assembly.CultureInfo -like $c) {
                        $hit = $true
                        break
                    }
                }
                if ($Culture -and -not $hit) {
                    continue
                }

                $hit = $false
                foreach ($p in $PublicKeyToken) {
                    if ($assembly.PublicKeyToken -like $p) {
                        $hit = $true
                        break
                    }
                }
                if ($PublicKeyToken -and -not $hit) {
                    continue
                }    

                $hit = $false
                foreach ($p in $ProcessorArchitecture) {
                    if ($assembly.ProcessorArchitecture -eq $p) {
                        $hit = $true
                        break
                    }
                }
                if ($ProcessorArchitecture -and -not $hit) {
                    continue
                }           

                $assembly
            }
        }
    }
}