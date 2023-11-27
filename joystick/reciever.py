import socket
import threading

def handle_sender(sender_socket, sender_address):
    print(f"Connected to {sender_address}")

    while True:
        message = sender_socket.recv(1024).decode()
        if not message:
            break
        print(f"Received message from {sender_address}: {message}")

    sender_socket.close()
    print(f"Connection with {sender_address} closed.")

def receiver():
    receiver_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    receiver_socket.bind(('127.0.0.1', 8888))
    receiver_socket.listen()

    print("Receiver is waiting for connections...")

    while True:
        sender_socket, sender_address = receiver_socket.accept()
        threading.Thread(target=handle_sender, args=(sender_socket, sender_address)).start()

if __name__ == "__main__":
    receiver()