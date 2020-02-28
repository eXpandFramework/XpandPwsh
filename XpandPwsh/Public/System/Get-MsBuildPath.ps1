function Get-MsBuildPath {
    [CmdLetTag("#msbuild")]
    param(

    )
    & "${env:ProgramFiles(x86)}\microsoft visual studio\installer\vswhere.exe" -latest -prerelease -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe 
}