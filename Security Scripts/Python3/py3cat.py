#!/usr/bin/env python3

import os
import sys
import socket
import argparse
import threading
import subprocess


# define some global variables
listen = False
command = False
upload = False
execute = ""
target = ""
upload_destination = ""
port = 0


# this runs a command and returns the output
def run_command(command):
    # trim the newline
    command = command.rstrip()

    # enabled change directory command
    if "cd" in command:
        directory = (command.rsplit('cd ', 1)[1])
        os.chdir(directory)

    # run the command and get the ouput back
    try:
        output = subprocess.check_output(
            command, stderr=subprocess.STDOUT, shell=True)
    except Exception as err:
        print(err)
        output = b"Failed to execute command.\r\n"
    # send the output back to the client
    return output


# this handles incoming client connections
def client_handler(client_socket):
    global upload
    global execute
    global command

    # check for upload
    if upload_destination is not None:
        # read in all of the bytes and write to our destination
        file_buffer = ""

        # keep reading data until none is available
        while True:
            data = client_socket.recv(1024)

            if not data:
                break
            else:
                file_buffer += data

        # now we take these bytes and try to write them out
        try:
            file_descriptor = open(upload_destination, "wb")
            file_descriptor.write(file_buffer)
            file_descriptor.close()

            # acknowledge that we wrote the file out
            client_socket.send(
                "Successfully saved file to %s\r\n" % upload_destination)
        except:
            client_socket.send("Failed to save file %s\r\n" %
                               upload_destination)

    # check for command execution
    if execute is not None:
        # run the command
        output = run_command(execute)
        client_socket.send(output)

    # now we go into another loop if a command shell was requested
    if command:
        while True:
            # show a simple prompt
            client_socket.send(b"PYCAT:#> ")

            # now we receive until we see a linefeed (enter key)
            cmd_buffer = ""
            while "\n" not in cmd_buffer:
                cmd_buffer += str(client_socket.recv(1024), 'utf-8')

            # we have a valid command so execute it and send back the results
            response = run_command(cmd_buffer)

            # send back the response
            client_socket.send(response)


# this is for incoming connections
def server_loop():
    global target
    global port

    # if no target is defined we listen on all interfaces
    if target is None:
        target = "0.0.0.0"

    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((target, port))
    server.listen(5)

    while True:
        client_socket, addr = server.accept()

        # spind off a thread to handle our new client
        client_thread = threading.Thread(
            target=client_handler, args=(client_socket,))
        client_thread.start()


# if we don't listen we are a client....make it so.
def client_sender(buffer):
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    try:
        # connect to our target host
        client.connect((target, port))

        # if we detect input from stdin send it
        # if not we are going to wait for the user to punch some in

        if len(buffer):
            client.send(buffer.encode())

        while True:

            # now wait for data back
            recv_len = 1
            response = ""

            while recv_len:
                data = str(client.recv(4096), 'utf-8')
                recv_len = len(data)
                response += data

                if recv_len < 4096:
                    break

            print (response,)

            # wait for more input
            buffer = input("")
            buffer += "\n"

            # send it off
            client.send(buffer.encode())

    except Exception as err:
        # just catch generic errors - you can do your homework to beef this up
        print(err)
        ## print ("[*] Exception! Exiting.")

        # teardown the connection
        client.close()


def main():
    global listen
    global port
    global execute
    global command
    global upload_destination
    global target

    parser = argparse.ArgumentParser()
    parser.add_argument("-l", "--listen", action="store_true", dest="listen",
                        help="listen on [host]:[port] for incoming connections")
    parser.add_argument("-e", "--execute", dest="execute",
                        help="execute the given file upon receiving a connection")
    parser.add_argument("-c", "--commandshell", action="store_true", dest="command",
                        help="initialize a command shell")
    parser.add_argument("-u", "--upload", dest="upload_destination",
                        help="upon receiving connection upload a file and write to [destination]")
    parser.add_argument("-t", "--target", dest="target",
                        help="host to connect to")
    parser.add_argument("-p", "--port", type=int, dest="port",
                        help="port of the target to connect to")

    if len(sys.argv[1:]) <= 0:
        parser.print_help()

    # read the commandline options
    args = parser.parse_args()

    listen = args.listen
    port = args.port
    execute = args.execute
    command = args.command
    upload_destination = args.upload_destination
    target = args.target

    # are we going to listen or just send data from stdin
    if not listen and target is not None and port > 0:
        # read in the buffer from the commandline
        # this will block, so send CTRL-D if not sending input
        # to stdin
        buffer = sys.stdin.read()

        # send data off
        client_sender(buffer)

    # we are going to listen and potentially
    # upload things, execute commands and drop a shell back
    # depending on our command line options above
    if listen:
        server_loop()


main()
