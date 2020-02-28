function ConvertTo-Directory {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        $Object
    )
    
    begin {
        
    }
    
    process {
        if (Test-Path $object -PathType Container) {
            $Object    
        }
        else{
            (Get-Item $Object).DirectoryName
        }
    }
    
    end {
        
    }
}