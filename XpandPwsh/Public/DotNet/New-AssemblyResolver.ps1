function New-AssemblyResolver{
    param(
        [parameter(ValueFromPipeline)]
        [string]$Path,
        [System.IO.FileInfo[]]$AssemblyList
    )
    . "$(Get-XpandPwshDirectoryName)\Private\AssemblyResolver.ps1"
    
    if ($AssemblyList){
        [AssemblyResolver]::new($AssemblyList)
    }
    else{
        [AssemblyResolver]::new($Path)
    }
}