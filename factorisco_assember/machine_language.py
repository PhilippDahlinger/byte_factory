def convert_to_word(line):
    opcode = line["opcode"]
    if (opcode < 20 and line["add_opcode"] == 1) or opcode == 23 or opcode == 24:
        # I Instruction
        assert -2 ** 11 <= line["imm"] < 2 ** 11
        # imm
        word = line["imm"] & 0xFFF
        # rs1
        word = ((word << 5) + line["rs1"]) & 0xFFFFFFFF
        # add opcode
        word = ((word << 3) + line["add_opcode"]) & 0xFFFFFFFF
        # rd
        word = ((word << 5) + line["rd"]) & 0xFFFFFFFF
        # opcode
        word = ((word << 7) + line["opcode"]) & 0xFFFFFFFF
    elif opcode < 20 and line["add_opcode"] == 2:
        # R Instruction
        word = line["rs2"] & 0xFFFFFFFF
        word = ((word << 5) + line["rs1"]) & 0xFFFFFFFF
        # add opcode
        word = ((word << 3) + line["add_opcode"]) & 0xFFFFFFFF
        # rd
        word = ((word << 5) + line["rd"]) & 0xFFFFFFFF
        # opcode
        word = ((word << 7) + line["opcode"]) & 0xFFFFFFFF
    elif 20 <= opcode <= 22 or opcode == 27 or opcode == 30:
        # U Instruction
        # view input as shifted 12 bits to the left
        word = line["imm"] & 0xFFFFF
        word = ((word << 5) + line["rd"]) & 0xFFFFFFFF
        # opcode
        word = ((word << 7) + line["opcode"]) & 0xFFFFFFFF
    elif 25 <= opcode <= 26:
        # S Instruction
        upper_imm = line["imm"] & 0xFE0
        upper_imm = upper_imm >> 5
        lower_imm = line["imm"] & 0x01F
        word = upper_imm
        # rs2
        word = ((word << 5) + line["rs2"]) & 0xFFFFFFFF
        # rs1
        word = ((word << 5) + line["rs1"]) & 0xFFFFFFFF
        # add opcode
        word = ((word << 3) + line["add_opcode"]) & 0xFFFFFFFF
        # lower imm
        word = ((word << 5) + lower_imm) & 0xFFFFFFFF
        # opcode
        word = ((word << 7) + line["opcode"]) & 0xFFFFFFFF
    else:
        raise ValueError(f"Wrong combination of opcode and add_opcode: {line}")
    if word >= 2**31:
        # interpret as negative number
        word -= 2**32
    return word

def create_machine_code(code, data):
    output_words = []
    for line in code:
        output_words.append(convert_to_word(line))
    for line in data:
        # every word is in its own list
        output_words.append(int(line[0]))
    return output_words


# if __name__ == "__main__":
#     code = [
#         {"opcode": 1, "rd": 1, "add_opcode": 1, "rs1": 0, "rs2": None, "imm": 1},
#         {"opcode": 1, "rd": 2, "add_opcode": 1, "rs1": 0, "rs2": None, "imm": 1},
#         {"opcode": 1, "rd": 1, "add_opcode": 2, "rs1": 1, "rs2": 2, "imm": None},
#         {"opcode": 1, "rd": 2, "add_opcode": 2, "rs1": 1, "rs2": 2, "imm": None},
#         {"opcode": 22, "rd": 3, "add_opcode": None, "rs1": None, "rs2": None, "imm": -2},
#     ]
#
#



