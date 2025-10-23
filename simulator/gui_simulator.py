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
        self.throttle_enabled = False
        self.throttle_target_ips = 100  # target instructions per second when throttled

        # Color display settings
        self.color_cell_size = 12  # each "pixel" size (px)
        self.color_rects = None    # 2D list of rectangle ids; built lazily

        # Build layout
        self._build_controls()
        self._build_register_view()
        self._build_display()       # includes text + color display (stacked)
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

        self.throttle_btn = ttk.Button(frame, text="⚡ Full Speed", command=self.toggle_throttle)
        self.throttle_btn.pack(side="left", padx=15)

    def _build_register_view(self):
        frame = ttk.LabelFrame(self.root, text="Register Stack (x0–x31)")
        frame.pack(side="left", fill="y", padx=5, pady=5)

        self.reg_labels = []
        for i in range(32):
            lbl = ttk.Label(frame, text=f"x{i:02}: 0", width=15)
            lbl.pack(anchor="w", padx=4)
            self.reg_labels.append(lbl)

    def _build_display(self):
        # Parent frame for both displays, stacked vertically
        frame = ttk.LabelFrame(self.root, text="Display")
        frame.pack(side="left", fill="both", expand=True, padx=5, pady=5)

        # --- Text display (existing) ---
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

        # --- Color display (new) ---
        # Placed below the text display inside the same group.
        # Uses a Canvas with pre-created rectangles for each pixel.
        color_container = ttk.Frame(frame)
        color_container.pack(fill="x", pady=(8, 0))

        ttk.Label(color_container, text="Color Display (32×32)").pack(anchor="w")

        # Create the canvas sized to the 32×32 grid
        w = 32 * self.color_cell_size
        h = 32 * self.color_cell_size
        self.color_canvas = tk.Canvas(
            color_container,
            width=w,
            height=h,
            bg="#101010",
            highlightthickness=0,
            bd=0,
        )
        self.color_canvas.pack()

        # Build the rectangle grid lazily; we may not have the controller yet at init time.
        self._ensure_color_grid()

    def _ensure_color_grid(self):
        """Create the 32×32 grid of rectangles once."""
        if self.color_rects is not None:
            return

        cols = 32
        rows = 32
        cs = self.color_cell_size

        self.color_rects = [[None for _ in range(cols)] for _ in range(rows)]
        for y in range(rows):
            y0 = y * cs
            for x in range(cols):
                x0 = x * cs
                rid = self.color_canvas.create_rectangle(
                    x0, y0, x0 + cs - 2, y0 + cs - 2, # small padding to distinguish pixels
                    outline="", fill="#000000"
                )
                self.color_rects[y][x] = rid

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
        focused_widget = self.root.focus_get()
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
        self._refresh_ui(full=True)

    def step(self):
        if not self.running:
            instruction = self.sim.address_room[self.sim.pc]
            if instruction != 30:
                self.sim.execute(instruction)
                self.sim.pc += 1
                # If your controllers require manual refresh(), call them here as needed.
                self.sim.display_controller.refresh()
                # If your color controller also needs it, uncomment:
                # self.sim.color_display_controller.refresh()
            self._refresh_ui(full=True)

    def toggle_throttle(self):
        self.throttle_enabled = not self.throttle_enabled
        if self.throttle_enabled:
            self.throttle_btn.config(text="🐢 100 IPS")
        else:
            self.throttle_btn.config(text="⚡ Full Speed")

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

            self.sim.execute(instruction)
            self.sim.pc += 1
            self.instr_counter += 1

            now = time.perf_counter()

            if self.throttle_enabled:
                time.sleep(1.0 / self.throttle_target_ips)

            # Update both displays at ~10 Hz
            if now - self.last_display_update >= 1 / self.display_fps:
                self._refresh_display_only()
                self.last_display_update = now

            # Compute IPS once per second
            if now - self.last_speed_time >= 1.0:
                self.ips_value = self.instr_counter / (now - self.last_speed_time)
                self.speed_label.config(text=f"Speed: {self.ips_value:,.0f} IPS")
                self.instr_counter = 0
                self.last_speed_time = now

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
        # Text display redraw (only when changed)
        new_text = "\n".join(self.sim.display_controller.current_display) + "\n"
        current_text = self.display_text.get("1.0", tk.END)
        if new_text != current_text:
            self.display_text.config(state="normal")
            self.display_text.delete("1.0", tk.END)
            self.display_text.insert(tk.END, new_text)
            self.display_text.config(state="disabled")

        # Color display redraw
        self._refresh_color_display()

    # --------------------------
    #   COLOR DISPLAY HELPERS
    # --------------------------

    def _refresh_color_display(self):
        """
        Redraw the 32×32 color grid from the color display controller,
        accepting either 24-bit ints (0xRRGGBB) or (r, g, b) tuples.
        """
        controller = getattr(self.sim, "color_display_controller", None)
        if controller is None:
            return

        # Ensure grid exists (in case this gets called before build)
        self._ensure_color_grid()

        # Try to obtain frame data from likely attribute names
        frame = getattr(controller, "current_frame", None)
        if frame is None:
            frame = getattr(controller, "pixels", None)
        if frame is None:
            return  # nothing to draw yet

        rows = min(32, len(frame))
        cols = min(32, len(frame[0]) if rows > 0 else 0)

        for y in range(rows):
            row = frame[y]
            for x in range(cols):
                val = row[x]
                fill = self._to_hex_color(val)
                self.color_canvas.itemconfig(self.color_rects[y][x], fill=fill)

    @staticmethod
    def _to_hex_color(val):
        """
        Convert either (r, g, b) with 0-255 each or a 24-bit int 0xRRGGBB
        into a Tk color string like '#RRGGBB'.
        """
        if isinstance(val, tuple) and len(val) == 3:
            r, g, b = val
        elif isinstance(val, int):
            r = (val >> 16) & 0xFF
            g = (val >> 8) & 0xFF
            b = val & 0xFF
        else:
            # Fallback to black if unexpected value
            r = g = b = 0
        return f"#{r:02x}{g:02x}{b:02x}"

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
