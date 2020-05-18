function Restore-GitFile {
    [CmdletBinding()]
    [CmdLetTag("#git")]
    param(
        [parameter(ValueFromPipeline)]
        [string]$File
    )
    
    begin {
        $root=Get-GitRootDirectory
    }
    
    process {
        $filePath= $File.Replace($root.FullName,"").Replace("\","/").Trim("/")
        Invoke-Script {git restore $filePath}
    }
    
    end {
        
    }
}