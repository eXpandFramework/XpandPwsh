function Clear-ProjectDirectories {
    param(
        $path=(Get-Location),
        $include=@("*/bin","*/obj","*/.vs","*/_Resharper*","*/packages","*.bak","*.log")
    )
    
    Get-ChildItem $path -Recurse -Include $include|Remove-Item -Force -Recurse
    
}