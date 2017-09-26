$port = 8000

$tcpListener = New-Object System.Net.Sockets.TcpListener $port
$tcpListener.Start()

$client = $tcpListener.AcceptTcpClient()
$clientConnections = $client
$clientStream = $client.GetStream()
Write-Verbose ("[$(Get-Date)] New Connection from {0} <{1}>!" -f
$client.Client.RemoteEndPoint.Address, $client.Client.RemoteEndPoint.Port) –Verbose


## Client Code to Connect to Server
# $Server = 'SERVERNAME-HERE'
# $Endpoint = new-object System.Net.IPEndpoint ([ipaddress]::any,$SourcePort)
# $Client = [Net.Sockets.TCPClient]$endpoint 
# $Client.Connect($Server,15600)