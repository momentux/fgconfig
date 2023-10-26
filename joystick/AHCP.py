import pygame
import time
from datetime import datetime

# Initialize pygame
pygame.init()

# Initialize the joystick module
pygame.joystick.init()

joystick_count = pygame.joystick.get_count()

if joystick_count == 0:
    print("[{}] No joystick detected.".format(datetime.now()))
else:
    # Open the first joystick (you can adjust the index if you have multiple joysticks)
    joystick = pygame.joystick.Joystick(0)
    joystick.init()

# Store previous states
prev_button_states = {}
prev_axis_values = {}
axis_names = {}
button_names = {}
# Create a dictionary to store the start time of button presses
button_press_start_time = {}

# Define the mappings for buttons 10, 11, 12, 13, and 0
button_mappings1 = {
    0: ("AHCP1_CENTER", 4016),
    10: ("AHCP1_UP", 4014),
    11: ("AHCP1_RIGHT", 4013),
    12: ("AHCP1_DN", 4015),
    13: ("AHCP1_LEFT", 4017)
}

# Define the mappings for buttons 6, 7, 8, 9, 1, and 2
button_mappings2 = {
    1: ("AHCP4_UP_LONG", 4011),
    2: ("AHCP4_CENTRE", 4012),
    6: ("AHCP4_UP", 4009),
    7: ("AHCP4_RIGHT", 4008),
    8: ("AHCP4_DN", 4010),
    9: ("AHCP4_LEFT", 4007)
}

# Main loop for reading input
running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        elif event.type == pygame.JOYHATMOTION:
            hat_value = joystick.get_hat(0)
            print(f"[{datetime.now()}] Hat Switch: {hat_value}")

    for i in range(joystick.get_numaxes()):
        axis_value = joystick.get_axis(i)
        axis_name = axis_names.get(i, f"Axis {i}")

        # Only print if the axis value has changed significantly (using a threshold)
        if i not in prev_axis_values or abs(prev_axis_values[i] - axis_value) > 0.1:
            print(f"[{datetime.now()}] {axis_name}: {axis_value:.2f}")
            prev_axis_values[i] = axis_value

    for i in range(joystick.get_numbuttons()):
        button_state = joystick.get_button(i)
        button_name = button_names.get(i, f"Button {i}")

        # Check if the button state has changed
        if i not in prev_button_states or prev_button_states[i] != button_state:
            if button_state:
                # Button is pressed
                button_press_start_time[i] = time.time()
                if i in button_mappings1:
                    action, value = button_mappings1[i]
                    print(f"{action}: {value} when pressed {button_name}")
                elif i in button_mappings2:
                    action, value = button_mappings2[i]
                    print(f"{action}: {value} when pressed {button_name}")
            else:
                # Button is released
                if i in button_press_start_time:
                    press_duration = time.time() - button_press_start_time[i]
                    if i == 3:
                        if press_duration >= 1.5:
                            print("AHCP2_LEFT_LONG: 4003")
                        else:
                            print("AHCP2_LEFT_SHORT: 4001")
                    elif i == 4:
                        if press_duration >= 1.5:
                            print("AHCP2_RIGHT_LONG: 4005")
                        else:
                            print("AHCP2_RIGHT_SHORT: 4002")
                    del button_press_start_time[i]
            prev_button_states[i] = button_state

    time.sleep(0.01)  # Reduce sleep time for more accurate button press timing

# Quit pygame and clean up
pygame.quit()
