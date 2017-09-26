$targetHost = "www.google.com"
$targetPort = 80   

# create socket object and stream
$client = New-Object Net.Sockets.TcpClient($targetHost, $targetPort)
$stream = $client.GetStream()

# create stream writer and send data
$writer = New-Object System.IO.StreamWriter($stream)
$headers = "GET / HTTP/1.1`r`nHost: google.com`r`n`r`n"
$writer.Write($headers)
$writer.Flush()

# receive some data
$buffer = New-Object System.Byte[] 4096
$encoding = New-Object System.Text.AsciiEncoding
$read = $stream.Read($buffer, 0, 4096)
Write-Host ($encoding.GetString($buffer, 0, $read))

$writer.Close()
$stream.Close()
