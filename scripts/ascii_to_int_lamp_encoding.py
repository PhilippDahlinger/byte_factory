import os
import tkinter as tk
from tkinter import messagebox
import json


class ASCIIGUI:
    def __init__(self):
        self.encodings = self.load_encodings()

        self.root = tk.Tk()
        self.root.title("ASCII 7x5 Font Editor")

        # Create a dropdown to select a character
        self.char_var = tk.StringVar(self.root)
        self.char_var.set(chr(32))  # Set default to space
        self.char_var.trace_add("write", self.refresh_button_colors)

        # Label to show the current character being modified
        self.char_label = tk.Label(self.root, text=f"Current Character: {self.char_var.get()}")
        self.char_label.pack()

        # Dropdown menu for selecting the character
        self.char_menu = tk.OptionMenu(self.root, self.char_var, *[chr(i) for i in range(32, 127)])
        self.char_menu.pack()

        # Initially load the grid for the default character
        self.frame = tk.Frame(self.root)
        self.frame.pack()
        self.buttons = self.create_character_grid(self.char_var.get())

        save_button = tk.Button(self.root, text="Save Encodings", command=self.save_button_click)
        save_button.pack()

        next_button = tk.Button(self.root, text="Next Character", command=self.next_char)
        next_button.pack()

        self.root.mainloop()

    # Next character button
    def next_char(self):
        current_char = self.char_var.get()
        next_char_code = ord(current_char) + 1
        if next_char_code > 126:  # Loop back to the start if beyond '~'
            next_char_code = 32  # Start from space again
        self.char_var.set(chr(next_char_code))
        self.refresh_button_colors()

    # Save button
    def save_button_click(self):
        self.save_encodings(self.encodings)
        messagebox.showinfo("Save", "Font encodings saved successfully!")

    # Define the 7x5 grid for each character's encoding (initially all False)
    def create_empty_grid(self):
        return [[False for _ in range(5)] for _ in range(7)]

    # Load font encodings from a JSON file (if exists)
    def load_encodings(self, file=os.path.join("output", "font_encodings.json")):
        try:
            with open(file, "r") as f:
                return json.load(f)
        except (FileNotFoundError, json.JSONDecodeError):
            return {chr(i): self.create_empty_grid() for i in
                    range(32, 127)}  # Create a default for all printable ASCII chars

    # Save font encodings to a JSON file
    def save_encodings(self, encodings, file=os.path.join("output", "font_encodings.json")):
        with open(file, "w") as f:
            json.dump(encodings, f)

    # Toggle the color of a button and update the encoding
    def toggle_button(self, row, col):
        char = self.char_var.get()
        self.encodings[char][row][col] = not self.encodings[char][row][col]
        self.refresh_button_colors()

    def refresh_button_colors(self, *args):
        char = self.char_var.get()
        for row in range(7):
            for col in range(5):
                color = 'black' if self.encodings[char][row][col] else 'white'
                self.buttons[row][col].config(bg=color)

    # Create a window with buttons for the current character encoding
    def create_character_grid(self, char):
        buttons = []

        for row in range(7):
            row_buttons = []
            for col in range(5):
                color = 'black' if self.encodings[char][row][col] else 'white'
                button = tk.Button(self.frame, width=2, height=1, bg=color,
                                   command=lambda r=row, c=col: self.toggle_button(r, c))
                button.grid(row=row, column=col)
                row_buttons.append(button)
            buttons.append(row_buttons)

        return buttons

    # Update the label that shows the current character
    def update_char_label(self):
        char = self.char_var.get()
        self.char_label.config(text=f"Current Character: {char}")


if __name__ == "__main__":
    ASCIIGUI()

#XXXXXXXXXXXXXX
#!0l1"#$%,.1457<=AEIdDaAbBceCfFgGhHjJkKmMnNpPqQrRsStTuUvVwWxXyYzZkK