# Set the system name to Windows to specify cross-compilation.
set(CMAKE_SYSTEM_NAME Windows)

# Specify the cross-compiler locations
set(CMAKE_C_COMPILER  /opt/homebrew/bin/x86_64-w64-mingw32-gcc)
set(CMAKE_CXX_COMPILER  /opt/homebrew/bin/x86_64-w64-mingw32-g++)

# Here you can set CMAKE_RC_COMPILER if you need to use a Windows resource compiler

# Set any other necessary toolchain specifics
# For example, you might need to set the sysroot or include directories,
# library directories, etc.
