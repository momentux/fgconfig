# joystick.py
import subprocess


# Import functions from file1.py
from AHCP_with_sender import sender_from_AHCP

# Import functions from file2.py
from Pilot_PG_Time_with_sender import sender_from_Pilot_PG_Time

# Import functions from file3.py
from T_throttle_warthog_Time_with_sender import sender_from_T_Throttle_Warthog_Time

# Import functions from file4.py
from VK_Time_with_sender import sender_from_VK_Time

# Import functions from file5.py
from VK1_time_with_sender import sender_from_VK1_Time

import os
import sys

# Set the working directory to the script's directory
os.chdir(os.path.dirname(os.path.realpath(__file__)))

# Define a log file path
log_file_path = "joystick_log.txt"

# Redirect stdout and stderr to the log file
sys.stdout = open(log_file_path, "a")
sys.stderr = open(log_file_path, "a")
# # Run each Python script using subprocess
# subprocess.run(["python", "AHCP_with_sender.py"])
# subprocess.run(["python", "Pilot_PG_Time_with_sender.py"])
# subprocess.run(["python", "T_throttle_warthog_Time_with_sender.py"])
# subprocess.run(["python", "VK_Time_with_sender.py"])
# subprocess.run(["python", "VK1_Time_with_sender.py"])



# Code to run the integrated functionality
if __name__ == "__main__":
    # Call functions or execute code from the integrated files
    sender_from_AHCP()
    sender_from_Pilot_PG_Time()
    sender_from_T_Throttle_Warthog_Time()
    sender_from_VK_Time()
    sender_from_VK1_Time()

