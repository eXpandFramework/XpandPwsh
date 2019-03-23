function Get-MsBuildPath {
    & "${env:ProgramFiles(x86)}\microsoft visual studio\installer\vswhere.exe" -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe | select-object -first 1
}