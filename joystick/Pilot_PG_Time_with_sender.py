import pygame
import time
from datetime import datetime
import socket

def initialize_socket():
    sender_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sender_socket.connect(('127.0.0.1', 8888))
    print("Sender 2 connected to the receiver.")
    return sender_socket

def initialize_joystick():
    pygame.init()
    pygame.joystick.init()

    joystick_count = pygame.joystick.get_count()

    if joystick_count == 0:
        print("[{}] No joystick detected.".format(datetime.now()))
        return None
    else:
        joystick = pygame.joystick.Joystick(0)
        joystick.init()
        return joystick

def send_message(sender_socket, message):
    print(message)
    sender_socket.send(message.encode())

def read_axis_data(joystick, prev_axis_values):
    for i in range(joystick.get_numaxes()):
        axis_value = joystick.get_axis(i)
        axis_name = f"Axis {i}"

        # Only print if the axis value has changed significantly (using a threshold)
        if i not in prev_axis_values or abs(prev_axis_values[i] - axis_value) > 0.1:
            print(f"[{datetime.now()}] {axis_name}: {axis_value:.2f}")
            prev_axis_values[i] = axis_value

def read_button_data(joystick, prev_button_states, button_mappings, sender_socket):
    for i in range(joystick.get_numbuttons()):
        button_state = joystick.get_button(i)

        # Check if the button state has changed
        if i not in prev_button_states or prev_button_states[i] != button_state:
            if button_state:
                # Button is pressed
                if i in button_mappings:
                    action, value = button_mappings[i]
                    message = f"[{datetime.now()}] {action}: {value}"
                    send_message(sender_socket, message)
            else:
                # Button is released
                pass

            prev_button_states[i] = button_state

def read_hat_switch(joystick, sender_socket):
    hat_values = joystick.get_hat(0)
    if hat_values == (1, 0):
        message = f"[{datetime.now()}] PG4_Right: 3001"
        send_message(sender_socket, message)
    elif hat_values == (-1, 0):
        message = f"[{datetime.now()}] PG4_Left: 3002"
        send_message(sender_socket, message)
    elif hat_values == (0, 1):
        message = f"[{datetime.now()}] PG4_Forward: 3004"
        send_message(sender_socket, message)
    elif hat_values == (0, -1):
        message = f"[{datetime.now()}] PG4_REAR: 3005"
        send_message(sender_socket, message)

def sender_from_Pilot_PG_Time():
    sender_socket = initialize_socket()
    joystick = initialize_joystick()

    if not joystick:
        print("Joystick not initialized. Exiting.")
        return

    # Store previous states
    prev_button_states = {}
    prev_axis_values = {}

    # Define the mappings for buttons 1, 2, and 3
    button_mappings = {
        3: ("PG8_LN", 3007),
        1: ("PG4_IN", 3001),
        2: ("PG8_IN", 3006),
    }

    try:
        while True:
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    return

            read_axis_data(joystick, prev_axis_values)
            read_button_data(joystick, prev_button_states, button_mappings, sender_socket)
            read_hat_switch(joystick, sender_socket)

            time.sleep(0.2)  # Reduce sleep time for more accurate button press timing

    finally:
        # Clean up
        sender_socket.close()
        pygame.quit()

if __name__ == "__main__":
    sender_from_Pilot_PG_Time()
