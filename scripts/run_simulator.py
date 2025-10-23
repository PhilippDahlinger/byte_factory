import yaml
import tkinter as tk

from simulator.gui_simulator import SimulatorGUI
from simulator.simulator import Simulator

if __name__ == "__main__":
    config = yaml.safe_load(open("simulator/sim_config_v3.yaml"))
    simulator = Simulator(config, [
        "output/factorisco/trainer_machine_code.txt",
        "output/factorisco/minesweeper_machine_code.txt",
    ])

    root = tk.Tk()
    gui = SimulatorGUI(root, simulator)
    root.mainloop()