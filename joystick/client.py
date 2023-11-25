# client.py

import socket

# Create a socket object
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Connect to the server
server_address = ('localhost', 5555)
client_socket.connect(server_address)

# Receive data from the server
received_data = client_socket.recv(1024).decode()
print("Received data:", received_data)

# Close the connection
client_socket.close()
