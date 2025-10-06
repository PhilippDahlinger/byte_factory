

class DisplayController:
    def __init__(self, config, simulator):
        self.config = config
        self.simulator = simulator
        self.width = self.config["width"]
        self.vis_height = self.config["vis_height"]
        self.total_height = self.config["total_height"]
        self.data = [[0] * self.width for _ in range(self.total_height)]
        self.first_displayed_row = 0
        self.address_map = self.config["address_map"]
        self.cursor_row = self.simulator.address_room[self.address_map["cursor_row"]]
        self.cursor_col = self.simulator.address_room[self.address_map["cursor_col"]]
        self.stride = 1  # will be set by boot
        self.wrap = False  # will be set by boot
        self.current_display = [" " * self.width for _ in range(self.vis_height)]  # will be set on refresh
        self.valid_addresses = set(self.address_map.values())
        self.special_chars = {
            128: "█",  # full block
            129: "■",  # square
            130: "▪",  # small square
            131: "◆",  # diamond
            132: "⎸", # left bar
            133: "‾", # top bar
            134: "⎹", # right bar
            135: "□", # empty square
            136: "░",  # shaded block
            137: "♣", # club
            138: "♠",  # spade
            139: "♥", # heart
            140: "♦", # diamond
        }


    def process(self, address, value):
        if address in self.valid_addresses:
            # check every address
            if address == self.address_map["cursor_row"]:
                self.cursor_row = value
            elif address == self.address_map["cursor_col"]:
                self.cursor_col = value
            elif address == self.address_map["first_displayed_row"]:
                self.first_displayed_row = value
            elif address == self.address_map["stride"]:
                self.stride = value
            elif address == self.address_map["wrap"]:
                self.wrap = bool(value)
            elif address == self.address_map["write_char"]:
                if 0 <= self.cursor_row < self.total_height and 0 <= self.cursor_col < self.width:
                    self.data[self.cursor_row][self.cursor_col] = value
                    # move cursor
                    self.cursor_col += self.stride
                    # wrap if needed
                    if self.cursor_col >= self.width and self.wrap:
                        self.cursor_col = 0
                        self.cursor_row += 1
                    # update memory-mapped cursor positions
                    self.simulator.address_room[self.address_map["cursor_row"]] = self.cursor_row
                    self.simulator.address_room[self.address_map["cursor_col"]] = self.cursor_col
            elif address == self.address_map["cls"]:
                self.data = [[0] * self.width for _ in range(self.total_height)]
            elif address == self.address_map["clear_current_row"]:
                if 0 <= self.cursor_row < self.total_height:
                    self.data[self.cursor_row] = [0] * self.width
            elif address == self.address_map["refresh"]:
                self.refresh()

    def refresh(self):
        new_display = []
        for row in range(self.first_displayed_row, self.first_displayed_row + self.vis_height):
            if 0 <= row < self.total_height:
                line_list = []
                for c in self.data[row]:
                    if 32 <= c <= 126:
                        line_list.append(chr(c))
                    elif c in self.special_chars:
                        line_list.append(self.special_chars[c])
                    else:
                        line_list.append(" ")
                line = "".join(line_list)
            else:
                line = " " * self.width
            new_display.append(line)
        self.current_display = new_display

    def print_display(self):
        print("-" * self.width)
        for line in self.current_display:
            print(line)
