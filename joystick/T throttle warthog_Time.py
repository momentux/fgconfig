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

# Main loop for reading input
running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        elif event.type == pygame.JOYHATMOTION:
            hat_value = joystick.get_hat(0)
            print(f"[{datetime.now()}] Hat Switch: {hat_value}")
            
     # Define axis mappings based on your joystick's configuration
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
                    print(f"[{datetime.now()}] {action}: {value}")
                elif i in button_mappings2:
                    action, value = button_mappings2[i]
                    print(f"[{datetime.now()}] {action}: {value}")
            else:
                # Button is released
                if i in button_press_start_time:
                    press_duration = time.time() - button_press_start_time[i]
                    if i == 2:
                        if press_duration >= 1.5:
                            print(f"[{datetime.now()}] T2_UP_LONG: 5003")
                        else:
                            print(f"[{datetime.now()}] T2_UP_SHORT: 5001")
                    elif i == 4:
                        if press_duration >= 1.5:
                            print(f"[{datetime.now()}] T2_DN_LONG: 5004")
                        else:
                            print(f"[{datetime.now()}] T2_DN_SHORT: 5002")
                    del button_press_start_time[i]
            prev_button_states[i] = button_state

    time.sleep(0.01)  # Reduce sleep time for more accurate button press timing

# Quit pygame and clean up
pygame.quit()
