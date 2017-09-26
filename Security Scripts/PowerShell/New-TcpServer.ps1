$Port = 8000

$TcpListener = New-Object Net.Sockets.TcpListener $Port
$TcpListener.Start()
$ConnectResult = $TcpListener.BeginAcceptTcpClient($null, $null)

Write-Verbose "Listening on 0.0.0.0:$Port [tcp]"

if (!$TcpClient) { Write-Warning "Connection to $($ServerIp.IPAddressToString):$Port [tcp] failed." ; return }

        
        
        

        # Write-Verbose "Connection from $($TcpClient.Client.RemoteEndPoint.ToString()) accepted."

        # $TcpStream = $TcpClient.GetStream()
        # $Buffer = New-Object Byte[] $TcpClient.ReceiveBufferSize

        # if ($PSBoundParameters.SslCn) { 
        #     $TcpStream = New-Object System.Net.Security.SslStream($TcpStream, $false)
        #     $Certificate = New-X509Certificate $SslCn
        #     $TcpStream.AuthenticateAsServer($Certificate)
        #     Write-Verbose "SSL Encrypted: $($TcpStream.IsEncrypted)"
        # }
        
        # $Properties = @{
        #     Socket = $TcpClient.Client
        #     TcpStream = $TcpStream
        #     Buffer = $Buffer
        #     Read = $TcpStream.BeginRead($Buffer, 0, $Buffer.Length, $null, $null)
        # }
        # New-Object psobject -Property $Properties
   
