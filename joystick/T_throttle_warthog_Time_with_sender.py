import pygame
import socket
import time
from datetime import datetime

def initialize_socket():
    sender_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sender_socket.connect(('127.0.0.1', 8888))
    print("[{}] Sender 3 connected to the receiver.".format(datetime.now()))
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

def print_hat_switch(joystick):
    hat_value = joystick.get_hat(0)
    print("[{}] Hat Switch: {}".format(datetime.now(), hat_value))

def print_axis_data(joystick, prev_axis_values):
    axis_names = {
        0: "Joystick X",
        1: "Joystick Y",
        2: "Throttle",
        3: "Rotary X",
        4: "Rotary Y",
        # Add more axes as needed
    }

    for i in range(joystick.get_numaxes()):
        axis_value = joystick.get_axis(i)
        axis_name = axis_names.get(i, f"Axis {i}")

        # Only print if the axis value has changed significantly (using a threshold)
        if i not in prev_axis_values or abs(prev_axis_values[i] - axis_value) > 0.1:
            print("[{}] {}: {:.2f}".format(datetime.now(), axis_name, axis_value))
            prev_axis_values[i] = axis_value

def send_button_press(sender_socket, action, value):
    message = "[{}] {}: {}".format(datetime.now(), action, value)
    sender_socket.send(message.encode())

def send_button_release(sender_socket, action, value):
    message = "[{}] {}: {}".format(datetime.now(), action, value)
    sender_socket.send(message.encode())

def sender_from_T_Throttle_Warthog_Time():
    sender_socket = initialize_socket()
    if not sender_socket:
        print("Failed to establish a socket connection. Exiting.")
        return

    joystick = initialize_joystick()
    if not joystick:
        print("Joystick not initialized. Exiting.")
        sender_socket.close()
        return

    # Store previous states
    prev_button_states = {}
    prev_axis_values = {}

    # Create a dictionary to store the start time of button presses
    button_press_start_time = {}

    # Define the mappings for buttons 10, 11, 12, 13, and 0
    button_mappings1 = {
        10: ("T10_IN", 5009),
        11: ("T11_IN", 5010),
        12: ("T8_LONG", 5011),
        13: ("T9_IN_L", 5013),
    }

    # Define the mappings for buttons 6, 7, 8, 9, 1, and 2
    button_mappings2 = {
        1: ("T2_LONG_RETURN", 5012),
        6: ("T4_IN", 5005),
        7: ("T7_IN", 5006),
        8: ("T8_IN", 5007),
        9: ("T9_IN", 5008)
    }

    try:
        while True:
            for event in pygame.event.get():
                if event.type == pygame.JOYHATMOTION:
                    print_hat_switch(joystick)

            print_axis_data(joystick, prev_axis_values)

            for i in range(joystick.get_numbuttons()):
                button_state = joystick.get_button(i)

                # Check if the button state has changed
                if i not in prev_button_states or prev_button_states[i] != button_state:
                    if button_state:
                        # Button is pressed
                        button_press_start_time[i] = time.time()
                        if i in button_mappings1:
                            action, value = button_mappings1[i]
                            send_button_press(sender_socket, action, value)
                        elif i in button_mappings2:
                            action, value = button_mappings2[i]
                            send_button_press(sender_socket, action, value)
                        else:
                            # Handle other buttons as needed
                            print("[{}] Button {}: Pressed".format(datetime.now(), i))
                    else:
                        # Button is released
                        if i in button_press_start_time:
                            press_duration = time.time() - button_press_start_time[i]
                            if i == 2:  # Modify this based on your button mapping
                                if press_duration >= 1.5:
                                    send_button_release(sender_socket, "T2_UP_LONG", 5003)
                                else:
                                    send_button_release(sender_socket, "T2_UP_SHORT", 5001)
                            elif i == 4:  # Modify this based on your button mapping
                                if press_duration >= 1.5:
                                    send_button_release(sender_socket, "T2_DN_LONG", 5004)
                                else:
                                    send_button_release(sender_socket, "T2_DN_SHORT", 5002)
                            else:
                                # Add more button release mappings as needed
                                print("[{}] Button {}: Released".format(datetime.now(), i))
                            del button_press_start_time[i]
                    prev_button_states[i] = button_state

            time.sleep(0.01)  # Reduce sleep time for more accurate button press timing

    finally:
        # Clean up
        sender_socket.close()
        pygame.quit()

if __name__ == "__main__":
    sender_from_T_Throttle_Warthog_Time()
