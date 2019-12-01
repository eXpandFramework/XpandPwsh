function Add-GitDiff{
    param(
        [parameter(Mandatory)]
        [string[]]$ExlcudeWildcard
    )
    git diff --name-only|Where-Object{
        $path=$_
        !($ExlcudeWildcard|Where-Object{$path -like $_}|Select-Object -first 1)
    }|ForEach-Object{
        git add $_
    }
}