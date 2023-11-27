import pywinusb.hid as hid
import datetime

# Define the Vendor and Product IDs for your Thrustmaster MFD Cougar V.2
VENDOR_ID = 0x044f  # Replace with your actual Vendor ID
PRODUCT_ID = 0xb351  # Replace with your actual Product ID

# Define a dictionary to map raw data patterns to button numbers
raw_data_to_button = {
    (0, 0, 0, 0, 4): 1,
    (0, 0, 0, 0, 8): 2,
    (0, 0, 0, 8, 0): 3,
    (0, 0, 0, 4, 0): 4,
    (0, 0, 0, 2, 0): 5,
    (0, 0, 0, 1, 0): 6,
    (0, 0, 128, 0, 0): 7,
    (0, 0, 0, 0, 1): 8,
    (0, 0, 0, 0, 2): 9,
    (0, 0, 0, 16, 0): 10,
    (0, 0, 0, 32, 0): 11,
    (0, 32, 0, 0, 0): 12,
    (0, 64, 0, 0, 0): 13,
    (0, 128, 0, 0, 0): 14,
    (0, 0, 1, 0, 0): 15,
    (0, 0, 2, 0, 0): 16,
    (0, 0, 0, 64, 0): 17,
    (0, 0, 0, 128, 0): 18,
    # Add more patterns and button numbers as needed
}

# Define a dictionary to map button numbers to VK codes for button events
button_to_vk = {
    1: {'VK_UP': 2001},
    2: {'VK_DN': 2002},
    3: {'VK_UP': 2003},
    4: {'VK_DN': 2004},
    5: {'VK_UP': 2005},
    6: {'VK_DN': 2006},
    8: {'VK_UP': 2007},
    9: {'VK_DN': 2008},
    10: {'VK_UP': 2009},
    11: {'VK_DN': 2010},
    12: {'VK_UP': 2011},
    13: {'VK_DN': 2012},
    14: {'VK_UP': 2013},
    15: {'VK_DN': 2014},
    17: {'VK_UP': 2015},
    18: {'VK_DN': 2016},
    # Add more button-to-VK mappings as needed
}

# Define the button press callback function
def on_button_pressed(data):
    button_number = raw_data_to_button.get(tuple(data))
    if button_number is not None:
        vk_mapping = button_to_vk.get(button_number)
        if vk_mapping is not None:
            for vk_key, vk_code in vk_mapping.items():
                timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                print(f"{timestamp} - {vk_key}: {vk_code}")

# Find and open the Thrustmaster MFD Cougar V.2 device
devices = hid.HidDeviceFilter(vendor_id=VENDOR_ID, product_id=PRODUCT_ID).get_devices()
if devices:
    device = devices[0]
    device.open()
    
    # Set the callback for button press events
    device.set_raw_data_handler(on_button_pressed)
    
    try:
        print("Waiting for button presses (Ctrl+C to exit)...")
        while True:
            pass  # Keep the script running to capture button presses
    except KeyboardInterrupt:
        pass
    finally:
        device.close()
else:
    print("Thrustmaster MFD Cougar V.2 not found. Check Vendor and Product IDs.")
