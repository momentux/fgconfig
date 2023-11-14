cmake_minimum_required(VERSION 3.10)
project ("Mil")

include_directories("lib")
link_directories("lib")

# Add source to this project's executable.
add_executable (mil main.cpp)
target_link_libraries(Mil "McxAPI")
