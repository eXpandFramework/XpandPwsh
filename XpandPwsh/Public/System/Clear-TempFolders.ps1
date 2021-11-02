function Clear-TempFolders {
    [CmdLetTag()]
    param(
        $tempfolders = @( "C:\Windows\Temp\*", "C:\Windows\Prefetch\*", "C:\Documents and Settings\*\Local Settings\temp\*", "C:\Users\*\Appdata\Local\Temp\*",$env:TEMP )
    )
    $tempfolders|ForEach-Object{
        Get-ChildItem $_|Remove-Item -Force -Recurse -ErrorAction Continue
    }
}