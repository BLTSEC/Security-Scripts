## New-FileServer.ps1
# Thanks to Chris Campbell
# https://gist.github.com/obscuresec/

[CmdletBinding()]
    Param(
       [Parameter(Mandatory=$False)]
       $port = 8000
    )

$Hso = New-Object Net.HttpListener
$Hso.Prefixes.Add("http://+:$port/")
$Hso.Start()

While ($Hso.IsListening) {
    $HC = $Hso.GetContext()
    $HRes = $HC.Response
    $HRes.Headers.Add("Content-Type","text/plain")
    $Buf = [Text.Encoding]::UTF8.GetBytes((Get-Content (Join-Path $Pwd ($HC.Request).RawUrl)))
    $HRes.ContentLength64 = $Buf.Length
    $HRes.OutputStream.Write($Buf,0,$Buf.Length)
    $HRes.Close()
}
$Hso.Stop()
$Hso.Dispose()