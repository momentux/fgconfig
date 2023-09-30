# CMakeList.txt : CMake project for Mil, include source and define
# project specific logic here.
#

include_directories("C:/Sital/COMposer/COMposer_4.5.3.1.32bit/DevPackage")
link_directories("C:/Sital/COMposer/COMposer_4.5.3.1.32bit/DevPackage")


# Add source to this project's executable.
add_executable (Mil "Mil.cpp" "Mil.h")
target_link_libraries(Mil "McxAPI" "McxAPIReturnCodes")


if (CMAKE_VERSION VERSION_GREATER 3.12)
  set_property(TARGET Mil PROPERTY CXX_STANDARD 20)
endif()

# TODO: Add tests and install targets if needed.
