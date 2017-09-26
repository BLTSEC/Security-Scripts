$targetHost = "127.0.0.1"
$targetPort = 80   

# create socket object and stream
$client = New-Object Net.Sockets.UdpClient
$client.Connect($targetHost, $targetPort)

$enc     = [System.Text.Encoding]::ASCII 
$message = "AAAAAAAAAAA`n"*10 
$buffer  = $enc.GetBytes($message) 

# Send the buffer 
$send = $client.Send($buffer, $buffer.Length)

$client.Close()