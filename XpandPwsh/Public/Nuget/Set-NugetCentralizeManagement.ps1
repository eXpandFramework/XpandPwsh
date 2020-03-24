function Set-NugetCentralizeManagement {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        

    )
    
    begin {
        
    }
    
    process {
        $projects=Get-ChildItem . *.csproj -Recurse

        $directoryProps="C:\Work\eXpandFramework\earthcape15\Projects\Directory.Packages.props"
        if (!(Test-Path $directoryProps)){
            Set-Content $directoryProps "<Project><ItemGroup></ItemGroup></Project>"
        }
        [xml]$props=Get-XmlContent $directoryProps
        $projects|Get-PackageReference|Sort-Object Include -Unique|ForEach-Object{
            $attributes=($_.Attributes|ForEach-Object{
                [PSCustomObject]@{
                    Name = $_.Name
                    Version=$_.Value
                }
            }|ConvertTo-Dictionary -KeyPropertyName Name -ValuePropertyName Version -Ordered )
            Add-XmlElement -Owner $props -ElementName PackageVersion -Parent ItemGroup -Attributes $attributes
        }
        $props|Save-Xml $directoryProps

        $projects|ForEach-Object{
            $package=Get-PackageReference $_
            $package|ForEach-Object{
                $_.RemoveAttribute("Version")
            }
            $owner=($package|Select-Object -First 1).OwnerDocument
            if ($owner){
                $owner|Save-Xml $_.FullName|Out-Null
            }
            
        }
    }
    
    end {
        
    }
}
