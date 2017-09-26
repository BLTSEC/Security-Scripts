import socket
import threading
bind_ip = "0.0.0.0"
bind_port = 9999

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server.bind((bind_ip, bind_port))

server.listen(5)

print ("[*] Listening on %s:%d" % (bind_ip, bind_port))

# handles incoming clinets using threading
def handle_client(client_socket):
    request = client_socket.recv(1024)
    print ("[*] Received: %s" % request.decode("utf-8"))

    # send back a packet and close
    client_socket.send(b"ACK!")
    client_socket.close()

while True:
    client, addr = server.accept()
    print ("[*] Accepted connection from: %s:%d" % \
        (addr[0], addr[1]))

    client_handler = threading.Thread(target=handle_client, args=(client,))
    client_handler.start()