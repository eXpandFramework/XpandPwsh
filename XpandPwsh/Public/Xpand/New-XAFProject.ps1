function New-XAFProject {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [ValidateSet("Core","Win","Web")]
        [parameter()][string]$Platform="Core",        

        [ArgumentCompleter({
            [OutputType([System.Management.Automation.CompletionResult])]  # zero to many
            param(
                [string] $CommandName,
                [string] $ParameterName,
                [string] $WordToComplete,
                [System.Management.Automation.Language.CommandAst] $CommandAst,
                [System.Collections.IDictionary] $FakeBoundParameters
            )
            (Get-XafPackageNames (get-devexpressversion))+(Get-xpandPackageNames)|sort-object|where-object{$_ -like "*$WordToComplete*"}
            
        })]
        [parameter()][string[]]$Packages=@(),
        [parameter()][string]$Name,
        [ValidateSet("Module","Application")]
        [parameter()][string]$Type="Application",
        [parameter()][string[]]$Source=(Get-PackageSource).Name,
        [ArgumentCompleter({
            [OutputType([System.Management.Automation.CompletionResult])]  # zero to many
            param(
                [string] $CommandName,
                [string] $ParameterName,
                [string] $WordToComplete,
                [System.Management.Automation.Language.CommandAst] $CommandAst,
                [System.Collections.IDictionary] $FakeBoundParameters
            )
            
            "net461","net472","net48"|where-object{$_ -like "$WordToComplete*"}
        })]
        [parameter()][string]$TargetFramework="net48",
        [parameter()][switch]$SkipBuild,
        [parameter()][switch]$Run
    )
    
    begin {
        if (!$name){
            $Name=(Get-Item (Get-Location)).Name
        }
        else{
            New-Item $Name -ItemType Directory
            Set-Location $Name 
        }

        $Source=ConvertTo-PackageSourceLocation $Source
        if (!$Packages|Select-String "DevExpress.ExpressApp.Core.All"){
            $Packages+=@("DevExpress.ExpressApp")
            
        }
        $Packages+=@("System.Configuration.Abstractions")

        if ($Type -eq "Application"){
            $Platform="Win"
            $Packages+=@("DevExpress.ExpressApp.$Platform","DevExpress.Persistent.BaseImpl")
            $Packages=$Packages|ForEach-Object{
                if ($_ -eq "All"){
                    "DevExpress.ExpressApp.Win.All"
                }
                else{
                    $_
                }
            }|Sort-Object -Unique
        }
        $Packages=$Packages|ForEach-Object{
            if ($_ -eq "All"){
                "DevExpress.ExpressApp.Core.All"
            }
            elseif ($_ -eq "All.Win"){
                "DevExpress.ExpressApp.Win.All"
            }
            elseif ($_ -eq "All.Web"){
                "DevExpress.ExpressApp.Web.All"
            }
            else{
                $_
            }
        }
    }
    
    process {
        $projectName=(Get-Item .).BaseName
        if ([char]::IsNumber($projectName[0])){
            $projectName="_$projectName"
        }
        $outputType="library"
        if ($Type -eq "Application"){
            $outputType="winexe"
            $solutionName="Solution$projectName"
            $startupObject="<StartupObject>$solutionName.Win.Program</StartupObject>"
            
            Get-ChildItem "$(Get-XpandPwshDirectoryName)\private\New-XafProject"|Copy-Item -Destination . -Force
            Get-ChildItem|Where-Object{$_ -like "*.cs" -or $_ -like "*.config"} |ForEach-Object{
                $c=Get-Content $_ -Raw
                $c=$c.Replace("`$SolutionName",$solutionName)
                Set-Content $_ $c
            }
            $systemReferences=@"
    <ItemGroup>
        <Reference Include="System.Windows.Forms" />
    </ItemGroup>
"@
        }
        
        
        $template=@"
<Project Sdk="Microsoft.NET.Sdk">
    <PropertyGroup>
    <TargetFramework>$TargetFramework</TargetFramework>
    <OutputType>$outputType</OutputType>
    $startupObject
    </PropertyGroup>
$systemReferences
</Project>
"@

        Set-Content ".\$projectName.csproj" $template
        $Packages|Add-PackageReference -source $Source
        $template=@"
        public class $($SolutionName)Module:DevExpress.ExpressApp.ModuleBase{
            public $($SolutionName)Module(){
                $ModuleRegistration
            }
        }
"@
        Set-Content ".\Module.cs" $template
        if (!$SkipBuild){
            dotnet build
        }
        $ModuleRegistration=(Get-XAFModule (Get-location)).FullName|Where-Object{$_ -notlike "*MiddleTier*"} |ForEach-Object{
            "RequiredModuleTypes.Add(typeof($_));`r`n`t`t`t`t"
        }
        $template=@"
        public class $($SolutionName)Module:DevExpress.ExpressApp.ModuleBase{
            public $($SolutionName)Module(){
                $ModuleRegistration
            }
        }
"@
        Set-Content ".\Module.cs" $template
        if (!$SkipBuild){
            dotnet build
        }
        if ($Run){
            Get-ChildItem *.exe -Recurse|ForEach-Object{
                & $_.FullName
            }
        }
    }
    
    end {
        
    }
}