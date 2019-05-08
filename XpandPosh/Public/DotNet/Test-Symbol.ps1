function Test-Symbol {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [System.IO.FileInfo]$pdb,
        [parameter()]
        [string]$file,
        [parameter()]
        [ValidateSet("Check","Match")]
        [string]$Mode="Check",
        [parameter()]
        [string]$chckMatch = "$PSScriptRoot\..\..\Private\ChkMatch.exe"
    )
    
    begin {
        if (!(test-path $chckMatch)) {
            throw "$chckMatch is invalid"
        }
        if (!$file) {
            $pdbFile = (get-item $pdb)
            $file = "$($pdbFile.DirectoryName)\$($pdbFile.BaseName).dll"
            if (!(Test-Path $file)) {
                throw [System.IO.FileNotFoundException]::new($file)
            }
        }
    }
    
    process {
        if ($Mode -eq "Check"){
            & $chckMatch -c $file $pdbFile.FullName
        }
        else{
            & $chckMatch -m $file $pdbFile.FullName
        }
    }
    
    end {
    }
}
