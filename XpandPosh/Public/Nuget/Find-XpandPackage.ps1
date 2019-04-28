function Find-XpandPackage {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline,Position=0)]
        [string]$Name,
        [parameter(Position=1)]
        [ValidateSet("All", "Release", "Lab")]
        [string]$PackageSource = "Release",
        [switch]$AllVersions,
        [int]$First=3
    )
    
    begin {
    }
    
    process {
        
        Write-Verbose ($fArgs|Out-String)
        $nuget=(Get-NugetPath)
        if ($PackageSource -eq "Lab"){
            $p=& ($nuget) list $name -Source (Get-PackageFeed -Xpand) 
        }
        elseif ($PackageSource -eq "All"){
            $p=(Find-XpandPackage -Name $Name -PackageSource Lab)+(Find-XpandPackage -Name $Name -PackageSource Release)
        }
        elseif ($PackageSource -eq "Release"){
            $p=& $nuget list author:eXpandFramework -Source (Get-PackageFeed -Nuget) |Where-Object{$_ -like $name}
        }
        $p|ConvertTo-PackageObject
        return
        (Find-Package "*$name*" -Source (Get-PackageFeed -xpand) -ProviderName Nuget|Invoke-Parallel -script{
            $sources=Get-PackageSource|Where-Object{$_.ProviderName -eq "Nuget"}    
            if ($PackageSource -eq "Release"){
                $sources=$sources|Where-Object{$_.Location -match (Get-PackageFeed -Nuget) }
            }
            elseif ($PackageSource -eq "Lab"){
                Find-Package "*$name*" -Source (Get-PackageFeed -xpand) -ProviderName Nuget
            }
            $packageName=$_.Name
            $sources|ForEach-Object{
                [PSCustomObject]@{
                    Name         = $packageName
                    ProviderName = "Nuget"
                    AllVersions=$AllVersions
                    ErrorAction="SilentlyContinue"
                    Source=$_.Name
                }
            }
        })|Invoke-Parallel -script{
            Find-Package $_.Name -Source $_.Source
            
        }
    }
    
    end {
    }
}