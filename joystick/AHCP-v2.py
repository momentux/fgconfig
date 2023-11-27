import pygame
import time
from datetime import datetime

class AhcpHandler:
    def __init__(self):
        pygame.init()
        pygame.joystick.init()

        self.joystick_count = pygame.joystick.get_count()
        self.prev_button_states = {}
        self.prev_axis_values = {}
        self.axis_names = {}
        self.button_names = {}
        self.button_press_start_time = {}

        self.button_mappings = {
            0: ("AHCP1_CENTER", 4016),
            1: ("AHCP4_UP_LONG", 4011),
            2: ("AHCP4_CENTRE", 4012),
            6: ("AHCP4_UP", 4009),
            7: ("AHCP4_RIGHT", 4008),
            8: ("AHCP4_DN", 4010),
            9: ("AHCP4_LEFT", 4007),
            10: ("AHCP1_UP", 4014),
            11: ("AHCP1_RIGHT", 4013),
            12: ("AHCP1_DN", 4015),
            13: ("AHCP1_LEFT", 4017),
        }

        if self.joystick_count > 0:
            self.joystick = pygame.joystick.Joystick(0)
            self.joystick.init()

    def run(self):
        running = True
        while running:
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    running = False
                    
            self.handle_hat_motion()
            self.handle_axes()
            self.handle_buttons()
            time.sleep(0.01)

    def handle_hat_motion(self):
        hat_value = self.joystick.get_hat(0)
        print(f"[{datetime.now()}] Hat Switch: {hat_value}")

    def handle_axes(self):
        for i in range(self.joystick.get_numaxes()):
            axis_value = self.joystick.get_axis(i)
            axis_name = self.axis_names.get(i, f"Axis {i}")

            if i not in self.prev_axis_values or abs(self.prev_axis_values[i] - axis_value) > 0.1:
                print(f"[{datetime.now()}] {axis_name}: {axis_value:.2f}")
                self.prev_axis_values[i] = axis_value

    def handle_buttons(self):
        for i in range(self.joystick.get_numbuttons()):
            button_state = self.joystick.get_button(i)
            button_name = self.button_names.get(i, f"Button {i}")

            if i not in self.prev_button_states or self.prev_button_states[i] != button_state:
                if button_state:
                    self.button_press_start_time[i] = time.time()
                    if i in self.button_mappings:
                        action, value = self.button_mappings[i]
                        print(f"{action}: {value} when pressed {button_name}")
                else:
                    self.handle_button_release(i)
                self.prev_button_states[i] = button_state

    def handle_button_release(self, button_index):
        if button_index in self.button_press_start_time:
            press_duration = time.time() - self.button_press_start_time[button_index]
        if button_index == 3:
            if press_duration >= 1.5:
                print("AHCP2_LEFT_LONG: 4003")
            else:
                print("AHCP2_LEFT_SHORT: 4001")
        elif button_index == 4:
            if press_duration >= 1.5:
                print("AHCP2_RIGHT_LONG: 4005")
            else:
                print("AHCP2_RIGHT_SHORT: 4002")
        del self.button_press_start_time[button_index]

    def cleanup(self):
        pygame.quit()

if __name__ == "__main__":
    joystick_handler = AhcpHandler()
    if joystick_handler.joystick_count == 0:
        print("No joystick detected.")
    else:
        joystick_handler.run()
    joystick_handler.cleanup()