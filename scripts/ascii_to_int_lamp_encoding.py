import os
import tkinter as tk
from tkinter import messagebox
import json

from bython_compiler.create_blueprint import blueprint_to_json, json_to_blueprint


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
    # ASCIIGUI()
    # get the blueprint of that
    m_blueprint = "0eNqdkd1OwzAMhd/F19lEq2ailXgSNE1pa5ilxOmSdDBVeXecFobggguUG8c/n09OFujtjFMgTtAtQIPnCN3zApFe2diSY+MQOiiVZDjtBu96YpN8gKyAeMR36Kp8VICcKBFugPVyO/HsegzSoP4CKZh8lFnPZaPw6od2rxXcSlTttSwaKeCwdTSqQFLw9tTj2VxJCDIWt3r8GYuUL40KXsgmDL+zn8LevB+Rd8MZYxJFl9lYeYEU2AcnXpStbjJhVdzB05qYi3FVVndefedR8P+kHeXk4igldFL8/iMFV9G/uqAPddu0rda6emwOTc4fmrSaNg=="
    all_256_signals = "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"
    all_signals = blueprint_to_json(all_256_signals)
    n_blueprint = m_blueprint
    m_json = blueprint_to_json(m_blueprint)
    n_json = blueprint_to_json(n_blueprint)
    with open ("output/signal_dict.json", "r") as f:
        signal_dict = json.load(f)
    with open("output/font_encodings.json", "r") as f:
        encodings = json.load(f)

    m_json["blueprint"]["entities"][0]["control_behavior"]["sections"]["sections"][0]["filters"] = []
    n_json["blueprint"]["entities"][0]["control_behavior"]["sections"]["sections"][0]["filters"] = []

    for i in range(32, 127):
        char = chr(i)
        bool_code = encodings[str(chr(i))]
        bool_array = [bool_code[0][0], bool_code[1][0], bool_code[2][0], bool_code[3][0], bool_code[4][0], bool_code[5][0], bool_code[6][0]]
        bool_array += [bool_code[0][1], bool_code[1][1], bool_code[2][1], bool_code[3][1], bool_code[4][1], bool_code[5][1], bool_code[6][1]]
        bool_array += [bool_code[0][2], bool_code[1][2], bool_code[2][2], bool_code[3][2]]
        m = n = 0
        for idx, b in enumerate(bool_array):
            if b:
                m += 2**idx
        bool_array = [bool_code[4][2], bool_code[5][2], bool_code[6][2]]
        bool_array += [bool_code[0][3], bool_code[1][3], bool_code[2][3], bool_code[3][3], bool_code[4][3], bool_code[5][3], bool_code[6][3]]
        bool_array += [bool_code[0][4], bool_code[1][4], bool_code[2][4], bool_code[3][4], bool_code[4][4], bool_code[5][4], bool_code[6][4]]
        for idx, b in enumerate(bool_array):
            if b:
                n += 2**idx
        signal = signal_dict[str(i)]
        template_signal_bp = all_signals["blueprint"]["entities"][0]["control_behavior"]["sections"]["sections"][0]["filters"][i]
        m_signal_bp = template_signal_bp.copy()
        m_signal_bp["count"] = m
        m_json["blueprint"]["entities"][0]["control_behavior"]["sections"]["sections"][0]["filters"].append(m_signal_bp)
        n_signal_bp = template_signal_bp.copy()
        n_signal_bp["count"] = n
        n_json["blueprint"]["entities"][0]["control_behavior"]["sections"]["sections"][0]["filters"].append(n_signal_bp)

    print(json_to_blueprint(m_json))
    print(json_to_blueprint(n_json))




#XXXXXXXXXXXXXX
#!0l1"#$%,.1457<=AEIdDaAbBceCfFgGhHjJkKmMnNpPqQrRsStTuUvVwWxXyYzZkK