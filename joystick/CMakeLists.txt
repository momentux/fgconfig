cmake_minimum_required(VERSION 3.10)
project(Joystick)

# Find SDL2
find_package(SDL2 REQUIRED)

# Add your source file here
add_executable(joystick main.cpp)

# Link SDL2
target_link_libraries(joystick PRIVATE SDL2::SDL2)

# Include SDL2 headers (may not be necessary if SDL2::SDL2 is properly configured)
# target_include_directories(joystick PRIVATE ${SDL2_INCLUDE_DIRS})
