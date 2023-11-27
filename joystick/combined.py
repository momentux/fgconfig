import pygame
import socket
from datetime import datetime
import time
import pywinusb.hid as hid

# Global socket variable
sender_socket = None

# Define the Vendor and Product IDs for your Thrustmaster MFD Cougar V.2
VENDOR_ID = 0x044f  # Replace with your actual Vendor ID
PRODUCT_ID = 0xb352
PRODUCT_ID1 = 0xb352


# Define a dictionary to map raw data patterns to button numbers


raw_data_to_button = {
    (0, 0, 0, 0, 4): 1,
    (0, 0, 0, 0, 8): 2,
    (0, 0, 0, 8, 0): 3,
    (0, 0, 0, 4, 0): 4,
    (0, 0, 0, 2, 0): 5,
    (0, 0, 0, 1, 0): 6,
    (0, 0, 128, 0, 0): 7,
    (0, 0, 0, 0, 1): 8,
    (0, 0, 0, 0, 2): 9,
    (0, 0, 0, 16, 0): 10,
    (0, 0, 0, 32, 0): 11,
    (0, 32, 0, 0, 0): 12,
    (0, 64, 0, 0, 0): 13,
    (0, 128, 0, 0, 0): 14,
    (0, 0, 1, 0, 0): 15,
    (0, 0, 2, 0, 0): 16,
    (0, 0, 0, 64, 0): 17,
    (0, 0, 0, 128, 0): 18,
    # Add more patterns and button numbers as needed
}

# Define a dictionary to map button numbers to VK codes for button events
button_to_vk = {
    1: {'VK_UP': 2001},
    2: {'VK_DN': 2002},
    3: {'VK_UP': 2003},
    4: {'VK_DN': 2004},
    5: {'VK_UP': 2005},
    6: {'VK_DN': 2006},
    8: {'VK_UP': 2007},
    9: {'VK_DN': 2008},
    10: {'VK_UP': 2009},
    11: {'VK_DN': 2010},
    12: {'VK_UP': 2011},
    13: {'VK_DN': 2012},
    14: {'VK_UP': 2013},
    15: {'VK_DN': 2014},
    17: {'VK_UP': 2015},
    18: {'VK_DN': 2016},
    # Add more button-to-VK mappings as needed
}

def initialize_socket():
    global sender_socket
    sender_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sender_socket.connect(('127.0.0.1', 8888))
    print("Socket connected to the receiver.")

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
    joystick = initialize_joystick()

    if joystick:
        send_joystick_data(joystick)

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
    joystick = initialize_joystick()

    if not joystick:
        print("Joystick not initialized. Exiting.")
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

def on_button_pressed_and_send(data, sender_socket):
    button_number = raw_data_to_button.get(tuple(data))
    if button_number is not None:
        vk_mapping = button_to_vk.get(button_number)
        if vk_mapping is not None:
            for vk_key, vk_code in vk_mapping.items():
                timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                message = f"{timestamp} - {vk_key}: {vk_code}"
                print(message)
                sender_socket.send(message.encode())

def initialize_device():
    # Find and open the Thrustmaster MFD Cougar V.2 device
    devices1 = hid.HidDeviceFilter(vendor_id=VENDOR_ID, product_id=PRODUCT_ID1).get_devices()

    if devices1:
        device = devices1[0]
        device.open()
        return device
    else:
        print("Thrustmaster MFD Cougar V.2 not found. Check Vendor and Product IDs.")
        return None

def cleanup(device, sender_socket):
    if device:
        device.close()
    if sender_socket:
        sender_socket.close()

def sender_from_VK_Time():
    sender_socket = None
    device = None

    try:
        sender_socket = initialize_socket()

        device = initialize_device()
        if not device:
            return

        # Set the callback for button press events
        device.set_raw_data_handler(lambda data: on_button_pressed_and_send(data, sender_socket))

        print("Waiting for button presses (Ctrl+C to exit)...")
        while True:
            pass  # Keep the script running to capture button presses

    except KeyboardInterrupt:
        pass
    finally:
        cleanup(device, sender_socket)

def initialize_device1():
    # Find and open the Thrustmaster MFD Cougar V.2 device
    devices = hid.HidDeviceFilter(vendor_id=VENDOR_ID, product_id=PRODUCT_ID).get_devices()

    if devices:
        device = devices[0]
        device.open()
        return device
    else:
        print("Thrustmaster MFD Cougar V.2 not found. Check Vendor and Product IDs.")
        return None

def cleanup(device, sender_socket):
    if device:
        device.close()
    if sender_socket:
        sender_socket.close()

def sender_from_VK1_Time():
    sender_socket = None
    device = None

    try:
        sender_socket = initialize_socket()

        device = initialize_device1()
        if not device:
            return

        # Set the callback for button press events
        device.set_raw_data_handler(lambda data: on_button_pressed_and_send(data, sender_socket))

        print("Waiting for button presses (Ctrl+C to exit)...")
        while True:
            pass  # Keep the script running to capture button presses

    except KeyboardInterrupt:
        pass
    finally:
        cleanup(device, sender_socket)

if __name__ == "__main__":
    try:
        initialize_socket()

        sender_from_AHCP()
        # Uncomment the desired sender function below
        sender_from_Pilot_PG_Time()
        sender_from_T_Throttle_Warthog_Time()
        sender_from_VK_Time()
        sender_from_VK1_Time()
    finally:
        if sender_socket:
            sender_socket.close()
