function Get-MsBuildPath {
    & "${env:ProgramFiles(x86)}\microsoft visual studio\installer\vswhere.exe" -latest -prerelease -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe 
}