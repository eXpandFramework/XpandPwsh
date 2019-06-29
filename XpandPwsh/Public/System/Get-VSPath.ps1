function Get-VSPath {
    & "${env:ProgramFiles(x86)}\microsoft visual studio\installer\vswhere.exe" -latest -prerelease -find **\devenv.exe 
}