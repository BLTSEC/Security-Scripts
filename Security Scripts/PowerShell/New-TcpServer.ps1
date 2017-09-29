function New-Server() {
    $port = 8000
    
    $tcpListener = New-Object System.Net.Sockets.TcpListener $port
    $tcpListener.Start()
    
    $client = $tcpListener.AcceptTcpClient()
    $clientConnections = $client
    $clientStream = $client.GetStream()
    Write-Verbose ("[$(Get-Date)] New Connection from {0} <{1}>!" -f
    $client.Client.RemoteEndPoint.Address, $client.Client.RemoteEndPoint.Port) –Verbose
}

# Start-Server -ip 192.168.2.2 -port 8000 | foreach { write-host ([char]$_) -NoNewLine }
function Start-Server([int]$port=2223, [string]$IPAdress="127.0.0.1", [switch]$Reply=$false){
    $listener = new-object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Parse($IPAdress), $port)
    $listener.start()
    [byte[]]$bytes = 0..255|%{0}
    write-host "Waiting for a connection on port $port..."
    $client = $listener.AcceptTcpClient()
    write-host "Connected from $($client.Client.RemoteEndPoint)"
    $stream = $client.GetStream()
    
    # could be used as an echo server
    # while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0)
    # {
    #     $bytes[0..($i-1)]|%{$_}

    # }

    $data = [System.Text.Encoding]::ASCII.GetBytes("ACK!!!!")
    if ($Reply){
        $stream.Write($data, 0, $data.Length)
    }
    $client.Close()
    $listener.Stop()
    write-host "Connection closed."
}

Start-Server -ip 127.0.0.1 -port 8000 -reply | foreach { write-host ([char]$_) -NoNewLine }

## Client Code to Connect to Server
# $Server = 'SERVERNAME-HERE'
# $Endpoint = new-object System.Net.IPEndpoint ([ipaddress]::any,$SourcePort)
# $Client = [Net.Sockets.TCPClient]$endpoint 
# $Client.Connect($Server,15600)