import time

import keyboard
import pyautogui

# Initialize the counter
counter = 152

def on_insert_press():
    global counter
    pyautogui.write(str(counter))  # Type the current number
    counter += 1  # Increment the counter
    time.sleep(0.5)  # Wait for a short moment

# Listen for the "insert" key press
keyboard.add_hotkey("insert", on_insert_press)

print("Press 'Insert' to type a number. Press 'Esc' to exit.")

# Keep the script running
keyboard.wait("esc")
