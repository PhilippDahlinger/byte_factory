import tkinter as tk
from tkinter import ttk
import threading
import time
import sv_ttk


class SimulatorGUI:
    def __init__(self, root, simulator):
        self.sim = simulator
        self.root = root
        self.root.title("FactoRISCo V Simulator")

        sv_ttk.set_theme("dark")

        # Control state
        self.running = False
        self.execution_thread = None
        self.last_display_update = 0.0
        self.display_fps = 10  # 10 Hz display refresh
        self.last_speed_time = 0.0
        self.instr_counter = 0
        self.ips_value = 0.0  # instructions per second

        # Build layout
        self._build_controls()
        self._build_register_view()
        self._build_display()
        self._build_memory_view()
        self._build_status()

        # Bind global keyboard input (except when addr_entry is focused)
        self.root.bind_all("<KeyPress>", self._on_global_key_pressed)

        self._refresh_ui(full=True)  # initial update

    # --------------------------
    #   GUI BUILDING
    # --------------------------

    def _build_controls(self):
        frame = ttk.Frame(self.root)
        frame.pack(fill="x", pady=5)

        self.start_btn = ttk.Button(frame, text="▶ Start", command=self.start)
        self.start_btn.pack(side="left", padx=5)

        self.pause_btn = ttk.Button(frame, text="⏸ Pause", command=self.pause)
        self.pause_btn.pack(side="left", padx=5)

        self.step_btn = ttk.Button(frame, text="⏭ Step", command=self.step)
        self.step_btn.pack(side="left", padx=5)

    def _build_register_view(self):
        frame = ttk.LabelFrame(self.root, text="Register Stack (x0–x31)")
        frame.pack(side="left", fill="y", padx=5, pady=5)

        self.reg_labels = []
        for i in range(32):
            lbl = ttk.Label(frame, text=f"x{i:02}: 0", width=15)
            lbl.pack(anchor="w", padx=4)
            self.reg_labels.append(lbl)

    def _build_display(self):
        frame = ttk.LabelFrame(self.root, text="Display")
        frame.pack(side="left", fill="both", expand=True, padx=5, pady=5)

        self.display_text = tk.Text(
            frame,
            width=self.sim.display_controller.width,
            height=self.sim.display_controller.vis_height,
            font=("Consolas", 10),
            bg="#202020",
            fg="#00ff88",
            insertbackground="#00ff88",
        )
        self.display_text.pack(fill="both", expand=True)
        self.display_text.config(state="disabled")

    def _build_memory_view(self):
        frame = ttk.LabelFrame(self.root, text="Memory Viewer (32 words)")
        frame.pack(side="left", fill="y", padx=5, pady=5)

        addr_frame = ttk.Frame(frame)
        addr_frame.pack(fill="x", pady=2)
        ttk.Label(addr_frame, text="Start Addr:").pack(side="left")
        self.addr_entry = ttk.Entry(addr_frame, width=10)
        self.addr_entry.pack(side="left", padx=5)
        self.addr_entry.insert(0, "0")

        ttk.Button(addr_frame, text="View", command=self.update_memory_view).pack(side="left")

        self.mem_text = tk.Text(
            frame,
            width=25,
            height=35,
            font=("Consolas", 9),
            bg="#202020",
            fg="#cccccc",
            insertbackground="#00ff88",
        )
        self.mem_text.pack(fill="both", expand=True)
        self.mem_text.config(state="disabled")

    def _build_status(self):
        frame = ttk.Frame(self.root)
        frame.pack(fill="x", pady=5)

        self.pc_label = ttk.Label(frame, text="PC: 0")
        self.pc_label.pack(side="left", padx=10)

        self.speed_label = ttk.Label(frame, text="Speed: 0 IPS")
        self.speed_label.pack(side="left", padx=20)

    # --------------------------
    #   KEYBOARD HANDLER
    # --------------------------

    def _on_global_key_pressed(self, event):
        """
        Capture all key presses in the window, except when typing
        into the start address entry field.
        """
        focused_widget = self.root.focus_get()

        # Skip capturing when the address field is focused
        if focused_widget == self.addr_entry:
            return

        key_symbol = event.keysym
        self.sim.keyboard_controller.add_pressed_key_to_queue(key_symbol)

    # --------------------------
    #   CONTROL HANDLERS
    # --------------------------

    def start(self):
        if not self.running:
            self.running = True
            self.execution_thread = threading.Thread(target=self._run_loop, daemon=True)
            self.execution_thread.start()

    def pause(self):
        self.running = False
        self._refresh_ui(full=True)  # full refresh when paused

    def step(self):
        if not self.running:
            instruction = self.sim.address_room[self.sim.pc]
            if instruction != 30:
                self.sim.execute(instruction)
                self.sim.pc += 1
                self.sim.display_controller.refresh()
            self._refresh_ui(full=True)

    # --------------------------
    #   RUN LOOP
    # --------------------------

    def _run_loop(self):
        self.last_speed_time = time.perf_counter()
        self.instr_counter = 0

        while self.running:
            instruction = self.sim.address_room[self.sim.pc]
            if instruction == 30:
                self.running = False
                break

            # Execute one instruction
            self.sim.execute(instruction)
            self.sim.pc += 1
            self.instr_counter += 1

            now = time.perf_counter()

            # Update display at ~10 Hz
            if now - self.last_display_update >= 1 / self.display_fps:
                self.sim.display_controller.refresh()
                self._refresh_display_only()
                self.last_display_update = now

            # Compute IPS once per second
            if now - self.last_speed_time >= 1.0:
                self.ips_value = self.instr_counter / (now - self.last_speed_time)
                self.speed_label.config(text=f"Speed: {self.ips_value:,.0f} IPS")
                self.instr_counter = 0
                self.last_speed_time = now

        # final refresh after run stops
        self._refresh_ui(full=True)

    # --------------------------
    #   UI REFRESH
    # --------------------------

    def _refresh_ui(self, full=False):
        self._refresh_display_only()
        self.pc_label.config(text=f"PC: {self.sim.pc}")
        self.speed_label.config(text=f"Speed: {self.ips_value:,.0f} IPS")

        if full:
            for i, lbl in enumerate(self.reg_labels):
                lbl.config(text=f"x{i:02}: {self.sim.reg_stack[i]}")
            self.update_memory_view(auto=True)

    def _refresh_display_only(self):
        """Only update display to minimize overhead during fast runs."""
        self.display_text.config(state="normal")
        self.display_text.delete("1.0", tk.END)
        for line in self.sim.display_controller.current_display:
            self.display_text.insert(tk.END, line + "\n")
        self.display_text.config(state="disabled")

    def update_memory_view(self, auto=False):
        try:
            start_addr = int(self.addr_entry.get())
        except ValueError:
            start_addr = 0
        end_addr = start_addr + 32
        self.mem_text.config(state="normal")
        self.mem_text.delete("1.0", tk.END)
        for addr in range(start_addr, min(end_addr, len(self.sim.address_room))):
            self.mem_text.insert(tk.END, f"{addr:06}: {self.sim.address_room[addr]}\n")
        self.mem_text.config(state="disabled")
