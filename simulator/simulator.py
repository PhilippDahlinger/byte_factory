import yaml


class Simulator:
    def __init__(self, config: dict, user_programs: list[str]):
        self.config = config
        # load all programs
        self.boot_code = self._load_program(config["boot_file"])
        self.os_code = self._load_program(config["os_file"])
        self.ecall_code = self._load_program(config["ecall_file"])
        self.user_codes = [self._load_program(f) for f in user_programs]
        assert len(self.user_codes) <= 4, "Maximum 4 user programs supported."

        self.reg_stack = [0] * 32
        self.address_room = [0] * 1000000
        self.pc = self.config["boot_address"]  # program counter starts at boot address
        self.display = None  # TODO: DisplaySimulator

        self.set_initial_memory()


    def run(self):
        while True:
            instruction = self.address_room[self.pc]
            print(f"PC: {self.pc}, Instruction: {instruction}")
            if instruction == 30:
                print("Encountered halt instruction (0). Halting.")
                break
            self.execute(instruction)

            self.pc += 1
            if self.pc >= len(self.address_room):
                print("Program counter out of bounds. Halting.")
                break

    def execute(self, instruction: int):
        """
        Execute a single instruction.
        :param instruction: The instruction to execute (as an integer).
        :return:
        """
        decoded = self.decode(instruction)
        print("Decoded instruction:", decoded)
        # arithmetic instructions
        if decoded["opcode"] < 20:
            a = self.reg_stack[decoded["rs1"]]
            # interpret as signed
            if a & (1 << 31):
                a -= 1 << 32
            if decoded["add_opcode"] == 1:
                # I instruction
                b = decoded["imm"]
            else:
                # R instruction
                b = self.reg_stack[decoded["rs2"]]
            if b & (1 << 31):
                b -= 1 << 32
            if decoded["opcode"] == 1:
                # ADD
                result = a + b
            elif decoded["opcode"] == 2:
                # SUB
                assert decoded["add_opcode"] == 2, "SUBI not supported."
                result = a - b
            elif decoded["opcode"] == 3:
                # MUL
                result = a * b
            elif decoded["opcode"] == 4:
                # DIV
                result = a // b if b != 0 else 0
            elif decoded["opcode"] == 5:
                # MOD
                result = a % b if b != 0 else 0
            elif decoded["opcode"] == 6:
                # EXP
                result = a ** b if b >= 0 else 0
            elif decoded["opcode"] == 7:
                # SLT (set less than)
                result = 1 if a < b else 0
            elif decoded["opcode"] == 8:
                # AND
                result = a & b
            elif decoded["opcode"] == 9:
                # OR
                result = a | b
            elif decoded["opcode"] == 10:
                # XOR
                result = a ^ b
            elif decoded["opcode"] == 11:
                # SRA (shift right arithmetic)
                result = a >> b
            elif decoded["opcode"] == 12:
                # SLL (shift left logical)
                result = (a << b) # in the end we will mask to 32 bits
            else:
                raise ValueError(f"Unknown arithmetic opcode: {decoded['opcode']}")
            wb = True
        elif decoded["opcode"] == 20:
            # LUI	x[rd] = sext(immediate[31:12] << 12)
            # imm already shifted
            result = decoded["imm"]
            wb = True
        elif decoded["opcode"] == 21:
            # AUIPC	x[rd] = pc + (sext(immediate[31:12] << 12))
            result = self.pc + decoded["imm"]
            wb = True
        elif decoded["opcode"] == 22:
            # JAL	x[rd] = pc+1; pc += sext(offset)
            result = self.pc + 1
            # make imm signed
            offset = decoded["imm"]
            if offset & (1 << 31):
                offset -= 1 << 32
            offset = offset >> 12 # because imm is shifted left by 12
            self.pc = (self.pc + offset) - 1  # -1 because we will increment pc after execution
            wb = True
        elif decoded["opcode"] == 23:
            # JALR	t =pc+1; pc=(x[rs1]+sext(offset)); x[rd]=t
            result = self.pc + 1
            offset = decoded["imm"]
            self.pc = (self.reg_stack[decoded["rs1"]] + offset) - 1  # -1 because we will increment pc after execution
            wb = True
        elif decoded["opcode"] == 24:
            # LW	x[rd] = sext(M[x[rs1] + sext(offset)][31:0])
            address = (self.reg_stack[decoded["rs1"]] + decoded["imm"])
            if address < 0 or address >= len(self.address_room):
                raise ValueError(f"Memory access out of bounds: {address}")
            result = self.address_room[address]
            wb = True
        elif decoded["opcode"] == 25:
            # SW	M[x[rs1] + sext(offset)][31:0] = x[rs2]
            address = (self.reg_stack[decoded["rs1"]] + decoded["imm"])
            if address < 0 or address >= len(self.address_room):
                raise ValueError(f"Memory access out of bounds: {address}")
            self.address_room[address] = self.reg_stack[decoded["rs2"]]
            result = None
            wb = False
        elif decoded["opcode"] == 26:
            # Branch instructions
            if decoded["add_opcode"] == 0:
                # BEQ	if (x[rs1] == x[rs2]) pc += sext(offset)
                condition = self.reg_stack[decoded["rs1"]] == self.reg_stack[decoded["rs2"]]
            elif decoded["add_opcode"] == 1:
                # BNE	if (x[rs1] != x[rs2]) pc += sext(offset)
                condition = self.reg_stack[decoded["rs1"]] != self.reg_stack[decoded["rs2"]]
            elif decoded["add_opcode"] == 2:
                # BLT	if (x[rs1] < x[rs2]) pc += sext(offset)
                condition = self.reg_stack[decoded["rs1"]] < self.reg_stack[decoded["rs2"]]
            elif decoded["add_opcode"] == 3:
                # BGE	if (x[rs1] >= x[rs2]) pc += sext(offset)
                condition = self.reg_stack[decoded["rs1"]] >= self.reg_stack[decoded["rs2"]]
            else:
                raise ValueError(f"Unknown branch add_opcode: {decoded['add_opcode']}")
            if condition:
                offset = decoded["imm"]
                self.pc = (self.pc + offset) - 1
            result = None
            wb = False
        elif decoded["opcode"] == 27:
            # ECALL: TODO
            result = None
            raise NotImplementedError
        elif decoded["opcode"] == 30:
            # NOP
            result = None
            wb = False
        else:
            raise ValueError(f"Unknown opcode: {decoded['opcode']}")
        if wb:
            # write back result to rd
            if decoded["rd"] != 0:
                # register x0 is always 0
                print("Writing back to register:", decoded["rd"], "Value:", result)
                self.reg_stack[decoded["rd"]] = result









    def decode(self, instruction: int) -> dict:
        # extract helper
        def extract(value, start, end):
            """Extract bits from 'end' to 'start' (inclusive)"""
            mask = (1 << (start - end + 1)) - 1
            return (value >> end) & mask

        def sign_extend(value, bits):
            """Sign extend a value with 'bits' bits"""
            sign_bit = 1 << (bits - 1)
            return (value & (sign_bit - 1)) - (value & sign_bit)

        # define bitfields
        opcode = extract(instruction, 6, 0)
        rd = extract(instruction, 11, 7)
        add_opcode = extract(instruction, 14, 12)
        rs1 = extract(instruction, 19, 15)
        rs2 = extract(instruction, 24, 20)
        # I instruction
        if (opcode <= 12 and add_opcode == 1) or opcode == 23 or opcode == 24:
            imm = extract(instruction, 31, 20)
            # sign extend
            imm = sign_extend(imm, 12)
        # S instruction
        elif opcode == 25 or opcode == 26:
            imm_lower = extract(instruction, 11, 7)
            imm_upper = extract(instruction, 31, 25)
            imm = (imm_upper << 5) | imm_lower
            # sign extend
            imm = sign_extend(imm, 12)
        # U instruction
        elif opcode == 20 or opcode == 21 or opcode == 22 or opcode == 27 or opcode == 30:
            imm = extract(instruction, 31, 12)
            # shift left by 12
            imm = imm << 12
        else:
            # R instruction
            imm = None
        return {
            "opcode": opcode,
            "add_opcode": add_opcode,
            "rd": rd,
            "rs1": rs1,
            "rs2": rs2,
            "imm": imm
        }

    def set_initial_memory(self):
        """
        Set the initial memory state with boot code, OS code, ecall code, and user programs.
        :return:
        """
        # load boot code
        boot_address = self.config["boot_address"]
        for i, word in enumerate(self.boot_code):
            self.address_room[i + boot_address] = word
        # load OS code
        os_address = self.config["os_address"]
        for i, word in enumerate(self.os_code):
            self.address_room[i + os_address] = word
        # load ecall code
        ecall_address = self.config["ecall_address"]
        for i, word in enumerate(self.ecall_code):
            self.address_room[i + ecall_address] = word
        # load user programs
        for program_idx, program in enumerate(self.user_codes):
            user_address = self.config["user_addresses"][program_idx]
            for i, word in enumerate(program):
                self.address_room[i + user_address] = word

    def _load_program(self, file_path: str) -> list[int]:
        with open(file_path, 'r') as f:
            lines = f.readlines()
        # convert to int
        return [int(line.strip()) for line in lines if line.strip()]


if __name__ == "__main__":
    config = yaml.safe_load(open("simulator/sim_config.yaml"))
    simulator = Simulator(config, [])
    simulator.run()