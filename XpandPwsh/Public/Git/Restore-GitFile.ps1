function Restore-GitFile {
    [CmdletBinding()]
    [CmdLetTag("#git")]
    param(
        [parameter(ValueFromPipeline)]
        [System.IO.FileInfo]$File
    )
    
    begin {
        $root=Get-GitRootDirectory
    }
    
    process {
        $filePath= $File.FullName.Replace($root.FullName,"").Replace("\","/").Trim("/")
        Invoke-Script {git restore $filePath}
    }
    
    end {
        
    }
}