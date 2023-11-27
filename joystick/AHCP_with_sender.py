import pygame
import socket
import time
from datetime import datetime

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

def send_button_event(sender_socket, action, value, button_state):
    state_description = "pressed" if button_state else "released"
    message = f"{action}: {value} when {state_description}"
    print(message)
    sender_socket.send(message.encode())

def process_button_events(joystick, sender_socket, prev_button_states, button_mappings):
    for i in range(joystick.get_numbuttons()):
        button_state = joystick.get_button(i)

        if i not in prev_button_states or prev_button_states[i] != button_state:
            action, value = button_mappings.get(i, ("Unknown", 0))
            send_button_event(sender_socket, action, value, button_state)
            prev_button_states[i] = button_state

def process_axis_events(joystick, prev_axis_values):
    for i in range(joystick.get_numaxes()):
        axis_value = joystick.get_axis(i)
        axis_name = f"Axis {i}"

        if i not in prev_axis_values or abs(prev_axis_values[i] - axis_value) > 0.1:
            print(f"[{datetime.now()}] {axis_name}: {axis_value:.2f}")
            prev_axis_values[i] = axis_value

def send_joystick_data(joystick, sender_socket):
    prev_button_states = {}
    prev_axis_values = {}

    button_mappings = {
        0: ("AHCP1_CENTER", 4016),
        10: ("AHCP1_UP", 4014),
        11: ("AHCP1_RIGHT", 4013),
        12: ("AHCP1_DN", 4015),
        13: ("AHCP1_LEFT", 4017),
        # Add more button mappings as needed
    }

    while True:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                return

        process_axis_events(joystick, prev_axis_values)
        process_button_events(joystick, sender_socket, prev_button_states, button_mappings)

        time.sleep(0.01)  # Reduce sleep time for more accurate button press timing

def sender_from_AHCP():
    sender_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sender_socket.connect(('127.0.0.1', 8888))

    print("Sender 1 connected to the receiver.")

    joystick = initialize_joystick()

    if joystick:
        send_joystick_data(joystick, sender_socket)

    sender_socket.close()

if __name__ == "__main__":
    sender_from_AHCP()
