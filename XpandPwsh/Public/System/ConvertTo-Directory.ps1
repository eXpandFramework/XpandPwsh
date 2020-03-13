function ConvertTo-Directory {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        $Object
    )
    
    begin {
        
    }
    
    process {
        if (Test-Path $object -PathType Container) {
            if ($Object -eq "."){
                get-item (Get-Location)
            }
            else{
                $Object    
            }
        }
        else{
            (Get-Item $Object).DirectoryName
        }
    }
    
    end {
        
    }
}