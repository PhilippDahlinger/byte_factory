from collections import deque


class KeyboardController:
    """
    KeyboardController captures key presses, translates them into integer codes,
    and stores them in a queue for the simulator to process.
    """

    def __init__(self, config, simulator):
        self.config = config
        self.simulator = simulator
        self.key_queue = deque()
        self.address_map = self.config["address_map"]
        self.valid_addresses = set(self.address_map.values())

        self.stream_open = False

    def add_pressed_key_to_queue(self, key_symbol):
        """
        Translates a pressed key into an integer code and appends it to the queue.
        :param key_symbol: str, e.g. 'a', 'A', 'Left', 'Return'
        """
        code = self._translate_key(key_symbol)
        if code is not None and self.stream_open:
            self.key_queue.append(code)

    def _translate_key(self, key_symbol: str) -> int | None:
        """
        Convert Tkinter key symbol to an integer ASCII value or custom code.
        """
        keymap = {
            "Right": 7,
            "Down": 8,
            "Left": 6,
            "Up": 9,
            "Return": 10,
            "BackSpace": 11,
            "space": 32,
        }

        # Check for special keys
        if key_symbol in keymap:
            return keymap[key_symbol]

        # Alphabetic keys (use uppercase ASCII)
        if len(key_symbol) == 1 and key_symbol.isalpha():
            return ord(key_symbol.upper())

        # Numeric and punctuation keys: use ASCII directly
        if len(key_symbol) == 1 and 32 <= ord(key_symbol) <= 126:
            return ord(key_symbol)

        # Ignore other keys for now
        return None

    def get_next_key(self) -> int | None:
        """Retrieve the next queued key code, or None if empty."""
        if self.key_queue:
            return self.key_queue.popleft()
        return None

    def process(self, address, value, is_write):
        if address in self.valid_addresses:
            # check every address
            if address == self.address_map["stream_content_output"] and not is_write:
                # get the next key from the queue, raise error if empty
                if self.key_queue:
                    next_key = self.key_queue.popleft()
                    self.simulator.address_room[self.address_map["stream_content_output"]] = next_key
                else:
                    raise RuntimeError("Keyboard input stream requested but no keys are available in the queue.")
            elif address == self.address_map["indicator_if_stream_not_empty"] and not is_write:
                self.simulator.address_room[self.address_map["indicator_if_stream_not_empty"]] = 1 if self.key_queue else 0
            elif address == self.address_map["open_stream"] and is_write:
                self.stream_open = bool(value)
            elif address == self.address_map["flush_stream"] and is_write:
                self.key_queue.clear()
