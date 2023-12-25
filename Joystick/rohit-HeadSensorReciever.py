import serial
import socket

# Define the serial port and baud rate
ser = serial.Serial('COM3', 9600)  # Update 'COM3' with your Arduino port

# Set up the socket connection
host = '127.0.0.1'  # Change this to the receiver's IP address or hostname
port = 8888       # Change this to an available port on the receiver

try:
    # Connect to the receiver
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((host, port))
        print(f"Connected to {host}:{port}")

        while True:
            # Read data from the serial port
            data = ser.readline().decode('utf-8').strip()

            # Print the received data
            print("Received:", data)

            # Send the data to the receiver
            s.sendall(data.encode('utf-8'))

except KeyboardInterrupt:
    # Close the serial port when the script is interrupted
    ser.close()
    print("Serial port closed.")
