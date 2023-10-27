cmake_minimum_required(VERSION 3.10)
project(fgfs)

set(CMAKE_CXX_STANDARD 14)

# Function to add a subproject
function(add_project PROJECT_NAME)
    if(NOT DEFINED BUILD_ALL AND NOT DEFINED ${PROJECT_NAME})
        return()
    endif()
    add_subdirectory(${PROJECT_NAME})
endfunction()

# Add projects
add_project(Mil)
add_project(Joystick)
