function Get-VSPath {
    [CmdLetTag("#visualstudio")]
    param()
    & "${env:ProgramFiles(x86)}\microsoft visual studio\installer\vswhere.exe" -latest -prerelease -find **\devenv.exe 
}