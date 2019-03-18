function Get-ChocoPackage {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        $filter
    )
    
    begin {
    }
    
    process {
        choco list $filter --lo|Where{$_ -like "$filter *"}|ForEach-Object{
            $strings=$_.split(";")
            [PSCustomObject]@{
                Name = $strings[0]
                Version =$strings[1]
            }
        }
    }
    
    end {
    }
}