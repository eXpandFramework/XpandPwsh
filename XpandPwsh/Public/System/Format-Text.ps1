function Format-Text {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory,ValueFromPipeline,Position=0)]
        [string]$Text,
        [parameter()]
        [int]$length,
        [switch]$Bold,
        [int]$UrlLength,
        [switch]$DoNotMemorize
    )
    
    begin {
        $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789".ToCharArray().GetEnumerator()|ConvertTo-Indexed
        $bold_chars = "𝗔","𝗕","𝗖","𝗗","𝗘","𝗙","𝗚","𝗛","𝗜","𝗝","𝗞","𝗟","𝗠","𝗡","𝗢","𝗣","𝗤","𝗥","𝗦","𝗧","𝗨","𝗩","𝗪","𝗫","𝗬","𝗭","𝗮","𝗯","𝗰","𝗱","𝗲","𝗳","𝗴","𝗵","𝗶","𝗷","𝗸","𝗹","𝗺","𝗻","𝗼","𝗽","𝗾","𝗿","𝘀","𝘁","𝘂","𝘃","𝘄","𝘅","𝘆","𝘇","𝟬","𝟭","𝟮","𝟯","𝟰","𝟱","𝟲","𝟳","𝟴","𝟵"
    }
    
    process {
        if ($bold){
            $Text=($Text.ToCharArray()|ForEach-Object{
                $c=$_
                $index=($chars|Where-Object{$_.Value -ceq $c}).Index
                if ($null -eq $index){
                    $c
                }
                else{
                    $bold_chars[$index]
                }
            }) -join ""
        }
        if ($length){
            if ($Text.Length -gt $length){
                if ($UrlLength){
                    $newUrl="|"*$UrlLength
                    $originalText=$Text
                    $regex = [regex] '(?imn)(?<url>\b(https?|ftp|file)://[-A-Z0-9+&@#/%?=~_|$!:,.;]*[A-Z0-9+&@#/%=~_|$])'
                    if ($regex.Matches($Text).Count -gt 1){
                        throw "Not implemented"
                    }
                    $result = $regex.Replace($Text, $newUrl)
                    if ($result.Length -gt $length){
                        $result=$result.Substring(0,$length-3)
                    }
                    $Text=$result.Replace($newUrl,$regex.Match($originalText).Groups["url"].value)
                }
            }
        }
        $Text
        if (!$DoNotMemorize){
            Set-Clipboard $Text
        }
    }
    
    end {
        
    }
}