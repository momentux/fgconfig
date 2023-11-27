#include <iostream>
#include <SDL2/SDL.h>
#include <map>
#include <string>
#include <chrono>

int main(int argc, char* argv[]) {
    // Initialize SDL
    if (SDL_Init(SDL_INIT_JOYSTICK) < 0) {
        std::cerr << "SDL could not initialize! SDL_Error: " << SDL_GetError() << std::endl;
        return 1;
    }

    // Initialize joystick
    int joystick_count = SDL_NumJoysticks();
    if (joystick_count == 0) {
        std::cout << "No joystick detected." << std::endl;
        return 0;
    }

    // Open the first joystick (you can adjust the index if you have multiple joysticks)
    SDL_Joystick* joystick = SDL_JoystickOpen(0);
    if (!joystick) {
        std::cerr << "Unable to open joystick! SDL_Error: " << SDL_GetError() << std::endl;
        return 1;
    }

    // Store previous states
    std::map<int, bool> prev_button_states;
    std::map<int, float> prev_axis_values;

    // Define button mappings
    std::map<int, std::pair<std::string, int>> button_mappings1 = {
        {0, {"AHCP1_CENTER", 4016}},
        {10, {"AHCP1_UP", 4014}},
        {11, {"AHCP1_RIGHT", 4013}},
        {12, {"AHCP1_DN", 4015}},
        {13, {"AHCP1_LEFT", 4017}}
    };

    std::map<int, std::pair<std::string, int>> button_mappings2 = {
        {1, {"AHCP4_UP_LONG", 4011}},
        {2, {"AHCP4_CENTRE", 4012}},
        {6, {"AHCP4_UP", 4009}},
        {7, {"AHCP4_RIGHT", 4008}},
        {8, {"AHCP4_DN", 4010}},
        {9, {"AHCP4_LEFT", 4007}}
    };

    // Main loop for reading input
    bool running = true;
    while (running) {
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            switch (event.type) {
                case SDL_QUIT:
                    running = false;
                    break;
                case SDL_JOYHATMOTION:
                    std::cout << "Hat Switch: " << static_cast<int>(event.jhat.value) << std::endl;
                    break;
                case SDL_JOYAXISMOTION:
                    {
                        float axis_value = static_cast<float>(event.jaxis.value) / 32767.0f;
                        int axis_id = event.jaxis.axis;
                        std::cout << "Axis " << axis_id << ": " << axis_value << std::endl;
                        prev_axis_values[axis_id] = axis_value;
                    }
                    break;
                case SDL_JOYBUTTONDOWN:
                case SDL_JOYBUTTONUP:
                    {
                        int button_id = event.jbutton.button;
                        bool button_state = (event.type == SDL_JOYBUTTONDOWN);

                        // Check if the button state has changed
                        if (!prev_button_states.count(button_id) || prev_button_states[button_id] != button_state) {
                            if (button_state) {
                                // Button is pressed
                                if (button_mappings1.count(button_id)) {
                                    auto [action, value] = button_mappings1[button_id];
                                    std::cout << action << ": " << value << " when pressed Button " << button_id << std::endl;
                                } else if (button_mappings2.count(button_id)) {
                                    auto [action, value] = button_mappings2[button_id];
                                    std::cout << action << ": " << value << " when pressed Button " << button_id << std::endl;
                                }
                            } else {
                                // Button is released
                                if (button_id == 3 || button_id == 4) {
                                    auto press_duration = std::chrono::duration_cast<std::chrono::milliseconds>(
                                        std::chrono::high_resolution_clock::now().time_since_epoch()
                                    ).count();
                                    if (press_duration >= 1500) {
                                        if (button_id == 3) {
                                            std::cout << "AHCP2_LEFT_LONG: 4003" << std::endl;
                                        } else if (button_id == 4) {
                                            std::cout << "AHCP2_RIGHT_LONG: 4005" << std::endl;
                                        }
                                    } else {
                                        if (button_id == 3) {
                                            std::cout << "AHCP2_LEFT_SHORT: 4001" << std::endl;
                                        } else if (button_id == 4) {
                                            std::cout << "AHCP2_RIGHT_SHORT: 4002" << std::endl;
                                        }
                                    }
                                }
                            }

                            prev_button_states[button_id] = button_state;
                        }
                    }
                    break;
                default:
                    break;
            }
        }

        SDL_Delay(10);  // Reduce delay for more accurate button press timing
    }

    // Quit SDL
    SDL_JoystickClose(joystick);
    SDL_Quit();

    return 0;
}
