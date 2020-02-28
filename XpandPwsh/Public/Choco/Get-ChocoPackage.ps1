function Get-ChocoPackage {
    [CmdletBinding()]
    [CmdLetTag("#chocolatey")]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        $filter
    )
    
    begin {
    }
    
    process {
        choco list $filter --lo|Where-Object{$_ -like "$filter *"}|ForEach-Object{
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