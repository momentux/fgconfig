import socket

def sender():
    # Create a socket
    sender_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    # Bind the socket to a specific address and port
    sender_socket.bind(('127.0.0.1', 8888))

    # Listen for incoming connections
    sender_socket.listen()

    print("Sender is waiting for a connection...")

    # Accept a connection from a receiver
    receiver_socket, receiver_address = sender_socket.accept()
    print(f"Connected to {receiver_address}")

    while True:
        # Get the message from the user
        message = input("Enter message: ")

        # Send the message to the receiver
        receiver_socket.send(message.encode())

    # Close the sockets
    sender_socket.close()
    receiver_socket.close()

if __name__ == "__main__":
    sender()
