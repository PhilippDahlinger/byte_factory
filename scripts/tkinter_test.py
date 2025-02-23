# Import tkinter module
from tkinter import *


# Function to change button color
def change_color():
    button.config(bg='red')  # Change the color to red


# Create a tkinter window
master = Tk()

# Open window having dimension 200x100
master.geometry('200x100')

# Create a Button with an initial color
button = Button(master,
                text='Submit',
                bg='blue',
                # Call change_color when the button is clicked
                command=change_color)
button.pack()

master.mainloop()
