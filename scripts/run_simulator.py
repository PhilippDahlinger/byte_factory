import yaml
import tkinter as tk

from factorisco_assember.assembler import kernel_program
from simulator.gui_simulator import SimulatorGUI
from simulator.simulator import Simulator

if __name__ == "__main__":

    # assemble kernel
    kernel_program("interrupt_handler_1_0", verbose=False)
    kernel_program("os_1_0", verbose=False)

    config = yaml.safe_load(open("simulator/sim_config_v3.yaml"))
    simulator = Simulator(config, ["output/factorisco/aoc2025_01_machine_code.txt",
                                   "output/factorisco/data/aoc25_01_input_machine_code.txt",
    ])

    root = tk.Tk()
    gui = SimulatorGUI(root, simulator)

    root.mainloop()
