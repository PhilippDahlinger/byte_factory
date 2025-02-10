code = [
    {"opcode": 1, "rd": 1,"add_opcode": 1, "rs1": 1,"rs2": None, "imm": 1},
    {"opcode": 1, "rd": 2,"add_opcode": 1, "rs1": 2,"rs2": None, "imm": 1},
    {"opcode": 1, "rd": 1,"add_opcode": 2, "rs1": 1,"rs2": 2, "imm": None},
    {"opcode": 1, "rd": 2,"add_opcode": 2, "rs1": 1,"rs2": 2, "imm": None},
    {"opcode": 1, "rd": 3,"add_opcode": None, "rs1": None,"rs2": None, "imm": -2},
]


def add_and_shift(x, shift, y):
    result = ((x << shift) + y) & 0xFFFFFFFF  # Ensure 32-bit wraparound
    if result & 0x80000000:  # Check if negative in 32-bit signed range
        result -= 0x100000000  # Convert to negative
    return result




# Example usage:
a = 2**29   # Some number
b = 200    # Number to add
shift = 1  # Number of bits to shift

res = add_and_shift(a, shift, b)
print(res)  # Output will be in signed 32-bit range
