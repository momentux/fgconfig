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

# Define the mappings for buttons 1, 2, and 3
button_mappings = {
    3: ("PG8_LN", 3007),
    1: ("PG4_IN", 3001),
    2: ("PG8_IN", 3006),
   
}

# Main loop for reading input
running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

    for i in range(joystick.get_numaxes()):
        axis_value = joystick.get_axis(i)
        axis_name = axis_names.get(i, f"Axis {i}")

        # Only print if the axis value has changed significantly (using a threshold)
        if i not in prev_axis_values or abs(prev_axis_values[i] - axis_value) > 0.1:
            print(f"[{datetime.now()}] {axis_name}: {axis_value:.2f}")
            prev_axis_values[i] = axis_value

    for i in range(joystick.get_numbuttons()):
        button_state = joystick.get_button(i)

        # Check if the button state has changed
        if i not in prev_button_states or prev_button_states[i] != button_state:
            if button_state:
                # Button is pressed
                button_press_start_time[i] = time.time()
                if i in button_mappings:
                    action, value = button_mappings[i]
                    print(f"[{datetime.now()}] {action}: {value}")
                elif i == 7:
                    print(f"[{datetime.now()}] PG9_IN")
                elif i == 13:
                    print(f"[{datetime.now()}] PG9_LN")

    # Read the hat switch values as four separate buttons
    hat_values = joystick.get_hat(0)
    if hat_values == (1, 0):
        print(f"[{datetime.now()}] PG4_Right: 3001")
    elif hat_values == (-1, 0):
        print(f"[{datetime.now()}] PG4_Left: 3002")
    elif hat_values == (0, 1):
        print(f"[{datetime.now()}] PG4_Forward: 3004")
    elif hat_values == (0, -1):
        print(f"[{datetime.now()}] PG4_REAR: 3005")

    time.sleep(0.2)  # Reduce sleep time for more accurate button press timing

# Quit pygame and clean up
pygame.quit()
