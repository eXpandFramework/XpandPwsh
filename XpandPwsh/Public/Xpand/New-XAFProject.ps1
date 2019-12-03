function New-XAFProject {
    [CmdletBinding()]
    param (
        [ValidateSet("Core","Win","Web")]
        [string]$Platform="Core",        

        [ArgumentCompleter({
            [OutputType([System.Management.Automation.CompletionResult])]  # zero to many
            param(
                [string] $CommandName,
                [string] $ParameterName,
                [string] $WordToComplete,
                [System.Management.Automation.Language.CommandAst] $CommandAst,
                [System.Collections.IDictionary] $FakeBoundParameters
            )
            get-xafpackages (get-devexpressversion)|where-object{$_ -like "$WordToComplete*"}
            
        })]
        [string[]]$XAFPackages,
        [ArgumentCompleter({
            [OutputType([System.Management.Automation.CompletionResult])]  # zero to many
            param(
                [string] $CommandName,
                [string] $ParameterName,
                [string] $WordToComplete,
                [System.Management.Automation.Language.CommandAst] $CommandAst,
                [System.Collections.IDictionary] $FakeBoundParameters
            )
            (((Find-XpandPackage * -PackageSource Release).id|ForEach-Object{
                $_.Replace("eXpand","").Replace("Xpand.XAF.Modules.","")
            })+@("All","All.Win","All.Web"))|Sort-Object -Unique|where-object{$_ -like "$WordToComplete*"}
            
        })]
        [string[]]$XpandPackages,
        [string]$Name,
        [ValidateSet("Module","Application")]
        [string]$Type="Module",
        [string]$Source=$env:dxfeed,
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
        [string]$TargetFramework="net48",
        [switch]$Force
    )
    
    begin {
        if (!$name){
            $Name=(Get-Item (Get-Location)).Name
        }
        else{
            New-Item $Name -ItemType Directory
            Set-Location $Name 
        }
        if (!$Source){
            throw "Source is not set, consider also `$env:dxfeed"
        }
        if (!$Packages){
            $Packages.Add("DevExpress.ExpresssApp.Core.all")
            $Packages.Add("DevExpress.ExpresssApp.$Platform.all")
        }
    }
    
    process {
        # $a=@("new")
        # if ($Type -eq "Module"){
        #     $a+="classlib"
        # }
        # if ($Force){
        #     $a+="--force"
        # }
        # dotnet @a
        $projectName="$((Get-Item .).BaseName).csproj"
        $template=@"
<Project Sdk="Microsoft.NET.Sdk">
    <PropertyGroup>
    <TargetFramework>$TargetFramework</TargetFramework>
    </PropertyGroup>
</Project>
"@

        Set-Content $projectName $template
        $Packages|ForEach-Object{
            $a="add","package",$_,"--source",$Source
            dotnet @a
        }
    }
    
    end {
        
    }
}