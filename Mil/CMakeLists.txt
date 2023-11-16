cmake_minimum_required(VERSION 3.10)

# Set your project name
project(Mil)

# Specify the C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Include directories for header files
include_directories(${PROJECT_SOURCE_DIR}/include)

# Source files
file(GLOB SOURCES "main.cpp")

# Add executable
add_executable(Mil ${SOURCES})

# Define the directory where your libraries are located
set(LIBRARY_DIR "${PROJECT_SOURCE_DIR}/lib")

# Collect all files in the specified directory
file(GLOB LIB_FILES "${LIBRARY_DIR}/*")

# Loop through each file
foreach(LIB_FILE IN LISTS LIB_FILES)
    # Get the filename without the path
    get_filename_component(LIB_NAME ${LIB_FILE} NAME_WE)

    # Attempt to find the library and add it
    find_library(FOUND_LIB NAMES ${LIB_NAME} PATHS ${LIBRARY_DIR})

    if(NOT FOUND_LIB)
        message(WARNING "Library ${LIB_NAME} not found in ${LIBRARY_DIR}")
    else()
        message(STATUS "Found library: ${FOUND_LIB}")
        target_link_libraries(Mil PRIVATE ${FOUND_LIB})
    endif()
endforeach()


# Link the libraries with the executable
target_link_libraries(Mil ${MCXAPI_LIBRARY})

