instruction_key_words = ["add", "addi", "and", "andi", "auipc", "beq", "bge", "bgeu", "blt", "bltu", "bne", "div",
                         "divu", "ecall", "add", "j", "jal", "jalr", "lb", "lbu", "lh", "lhu", "lui", "lw", "mul",
                         "mulh", "mulhsu", "mulhu", "or", "ori", "rem", "addi", "remu", "sb", "sh", "sll", "slli",
                         "slt", "slti", "sltiu", "sltu", "sra", "srai", "srl", "srli", "sub", "sw", "xor", "and",
                         "xori", "beqz", "bgez", "bgt", "bgtu", "bgtz", "ble", "bleu", "blez", "bltz", "bnez", "andi",
                         "call", "jal", "jalr", "j", "jr", "la", "lb", "lbu", "lh", "lhu", "li", "lw", "mv", "neg",
                         "nop", "ret", "not", "auipc", "ret", "sb", "seqz", "sgtz", "sh", "sltz", "snez", "sw", "tail",
                         "seq", "beq", "sge", "sgeu", "sgt", "sgtu", "sle", "sleu", "sne", "push", "pop", "subi"
                         ]
reg_key_words = [
    "x0", "x1", "x2", "x3", "x4", "x5", "x6", "x7", "x8", "x9", "x10", "x11", "x12", "x13", "x14", "x15", "x16", "x17",
    "x18", "x19", "x20", "x21", "x22", "x23", "x24", "x25", "x26", "x27", "x28", "x29", "x30", "x31", "zero", "ra",
    "sp", "gp", "tp", "t7", "t0", "t1", "t2", "s0", "fp", "s1", "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7", "s2",
    "s3", "s4", "s5", "s6", "s7", "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
]

assembler_directives = [
    ".data", ".text", ".macro", ".endm", ".if", ".else", ".endif", ".globl", ".align", ".byte", ".half", ".word",
    ".dword", ".asciz", ".space", ".double"
]

branch_instructions = [ "jal", "jalr", "beq", "bne", "blt", "bge"]

riscv_reg_translator = {
    "zero": "x0",
    "ra": "x1",
    "sp": "x2",
    "gp": "x3",
    "tp": "x4",
    "t7": "x4",  # in FactoRISCo V, there is no thread pointer and we can use it as a temp reg
    "t0": "x5",
    "t1": "x6",
    "t2": "x7",
    "s0": "x8",
    "fp": "x8",  # Same register as s0
    "s1": "x9",
    "a0": "x10",
    "a1": "x11",
    "a2": "x12",
    "a3": "x13",
    "a4": "x14",
    "a5": "x15",
    "a6": "x16",
    "a7": "x17",
    "s2": "x18",
    "s3": "x19",
    "s4": "x20",
    "s5": "x21",
    "s6": "x22",
    "s7": "x23",
    "s8": "x24",
    "s9": "x25",
    "s10": "x26",
    "s11": "x27",
    "t3": "x28",
    "t4": "x29",
    "t5": "x30",
    "t6": "x31"
}

instruction_translator = {
    "addi": (1, 1),
    "muli": (3, 1),
    "divi": (4, 1),
    "modi": (5, 1),
    "expi": (6, 1),
    "slti": (7, 1),
    "andi": (8, 1),
    "ori": (9, 1),
    "xori": (10, 1),
    "srai": (11, 1),
    "slli": (12, 1),
    "add": (1, 2),
    "sub": (2, 2),
    "mul": (3, 2),
    "div": (4, 2),
    "mod": (5, 2),
    "exp": (6, 2),
    "slt": (7, 2),
    "and": (8, 2),
    "or": (9, 2),
    "xor": (10, 2),
    "sra": (11, 2),
    "sll": (12, 2),
    "lui": (20, None),
    "auipc": (21, None),
    "jal": (22, None),
    "jalr": (23, 0),
    "lw": (24, 0),
    "sw": (25, 0),
    "beq": (26, 0),
    "bne": (26, 1),
    "blt": (26, 2),
    "bge": (26, 3),
    "halt": (30, None),
}


def split_up_imm(imm):
    """
    If imm is outside [-2**11, 2**11 -1], it needs to be split up in a lower and an upper part
    :param imm:
    :return: (is_split, upper, lower)
    if is_split is False, upper is 0
    """
    if -2048 <= imm <= 2047:
        return False, 0, imm
    else:
        # make sure imm is in range of 32 bit values
        assert -2 ** 31 <= imm <= 2 ** 31, f"imm value {imm} is bigger than a 32 bit number."
        upper = (imm + (1 << 11)) >> 12  # round up to handle edge case nubers between 2048 and 4096
        lower = imm - (upper << 12)
        return True, upper, lower


def get_text_segment(code):
    def get_directive(key_word):
        directive = [(i, line) for (i, line) in enumerate(code) if line.startswith(key_word)]
        assert len(directive) <= 1, f"Only 1 {key_word} segment allowed in code!"
        if len(directive) == 0:
            return None
        i, line = directive[0]
        assert directive[0][1].strip() == key_word, f"Invalid line {i}: `{line}`"
        return i

    text_directive = get_directive(".text")
    data_directive = get_directive(".data")
    if data_directive is not None and text_directive < data_directive:
        text_segment = code[text_directive + 1:data_directive]
    else:
        # either no data segment or data segment was before the text segment
        text_segment = code[text_directive + 1:]
    return text_segment


def tokenize(code):
    output = []
    _start_found = False
    _start_label_found = False
    for i, line in enumerate(code):
        tokens = line.split(" ")
        tokens = [x.strip() for x in tokens]
        assert len(tokens) > 0, f"Error parsing empty line {i}: `{line}`"
        if tokens[0] == ".globl" and tokens[1] == "_start":
            # entry point def: jump to start
            _start_found = True
            tokens = ["j", "_start"]
        # check for basic syntax
        # labels
        if tokens[0].endswith(":"):
            if tokens[0] == "_start:":
                _start_label_found = True
            assert ":" not in tokens[0][:-1], f"label `{line}` in line {i} contains illegal character `:`"
            assert len(tokens) == 1, f"Label definition `{line}` in line {i} contains multiple words"
        # instructions
        assert "," not in tokens[0], f"Error parsing line {i}: `{line}`"
        smaller_tokens = [tokens[0]]
        for arg in tokens[1:]:
            if "," in arg:
                split_tokens = arg.split(",")
                split_tokens = [x.strip() for x in split_tokens]
                split_tokens = [x for x in split_tokens if x != ""]
                smaller_tokens += split_tokens
            else:
                smaller_tokens.append(arg)
        tokens = smaller_tokens
        # more checks?
        output.append(tokens)
    assert _start_found and _start_label_found, "Could not find `.globl _start` in the code. Needs to present to define the entry point"
    return output


def replace_pseudo_instructions(code):
    output = []
    for i, tokens in enumerate(code):
        if tokens[0].endswith(":"):
            # found label
            output.append(tokens)
            continue
        instr = tokens[0]
        # check all possible pseudo instructions
        if instr == "mv":
            assert len(tokens) == 3, f"Wrong numbers of arguments for `mv` in line {i}"
            output.append(["addi", tokens[1], tokens[2], "0"])
        elif instr == "li":
            assert len(tokens) == 3, f"Wrong numbers of arguments for `li` in line {i}"
            try:
                imm = int(tokens[-1])
            except ValueError:
                raise ValueError(f"Error parsing immediate value {tokens[-1]} in line {i}")
            is_split, upper, lower = split_up_imm(imm)
            if is_split:
                # 2 lines
                output.append(["lui", tokens[1], str(upper)])
                output.append(["addi", tokens[1], tokens[1], str(lower)])
            else:
                # directly addi
                output.append(["addi", tokens[1], "zero", str(lower)])
        elif instr == "neg":
            assert len(tokens) == 3, f"Wrong numbers of arguments for `neg` in line {i}"
            output.append(["sub", tokens[1], "zero", tokens[2]])
        elif instr == "not":
            assert len(tokens) == 3, f"Wrong numbers of arguments for `not` in line {i}"
            output.append(["xori", tokens[1], tokens[2], "-1"])
        elif instr == "subi":
            assert len(tokens) == 4, f"Wrong numbers of arguments for `subi` in line {i}"
            if tokens[3].startswith("-"):
                imm = tokens[3][1:]
            else:
                imm = "-" + tokens[3]
            output.append(["addi", tokens[1], tokens[2], imm])
        elif instr == "beqz":
            assert len(tokens) == 3, f"Wrong numbers of arguments for `beqz` in line {i}"
            output.append(["beq", tokens[1], "zero", tokens[2]])
        elif instr == "bnez":
            assert len(tokens) == 3, f"Wrong numbers of arguments for `bnez` in line {i}"
            output.append(["bne", tokens[1], "zero", tokens[2]])
        elif instr == "bgt":
            assert len(tokens) == 4, f"Wrong numbers of arguments for `bgt` in line {i}"
            output.append(["blt", tokens[2], tokens[1], tokens[3]])
        elif instr == "ble":
            assert len(tokens) == 4, f"Wrong numbers of arguments for `ble` in line {i}"
            output.append(["bge", tokens[2], tokens[1], tokens[3]])
        elif instr == "j":
            assert len(tokens) == 2, f"Wrong numbers of arguments for `j` in line {i}"
            output.append(["jal", "zero", tokens[1]])
        elif instr == "jr":
            assert len(tokens) == 2, f"Wrong numbers of arguments for `jr` in line {i}"
            output.append(["jalr", "zero", f"0({tokens[1]})"])
        elif instr == "nop":
            assert len(tokens) == 1, f"Wrong numbers of arguments for `nop` in line {i}"
            output.append(["addi", "zero", "zero", "0"])
        elif instr == "la":
            raise NotImplementedError()
        elif instr == "call":
            assert len(tokens) == 2, f"Wrong numbers of arguments for `call` in line {i}"
            output.append(["jal", "ra", tokens[1]])
        elif instr == "ret":
            assert len(tokens) == 1, f"Wrong numbers of arguments for `ret` in line {i}"
            output.append(["jalr", "zero", "0(ra)"])
        elif instr == "push":
            assert len(tokens) == 2, f"Wrong numbers of arguments for `push` in line {i}"
            output.append(["addi", "sp", "sp", "-4"])
            output.append(["sw", tokens[1], "0(sp)"])
        elif instr == "pop":
            assert len(tokens) == 2, f"Wrong numbers of arguments for `pop` in line {i}"
            output.append(["lw", tokens[1], "0(sp)"])
            output.append(["addi", "sp", "sp", "4"])
        # implement more if needed
        else:
            # no pseudo instruction
            output.append(tokens)
    return output

def replace_reg_names(code):
    # DEPRECATED, INFER REG NUMBER DIRECTLY, POSSIBLY FROM NICKNAME


    for i, tokens in enumerate(code):
        for j in range(len(tokens)):
            if tokens[j] in riscv_reg_translator:
                tokens[j] = riscv_reg_translator[tokens[j]]
    return code


def collect_labels(code):
    labels = {}
    output_code = []
    address = 0
    for i, tokens in enumerate(code):
        if tokens[0].endswith(":"):
            label = tokens[0][:-1]
            assert label not in labels, f"label `{label}` defined multiple times"
            assert i != len(code) - 1, f"Label `{label}` set at end of file defining no address"
            assert label not in instruction_key_words, f"Label `{label}` in line {i} is an instruction key word"
            assert label not in assembler_directives, f"Label `{label}` in line {i} is an assembler directive"
            assert label not in reg_key_words, f"Label `{label}` in line {i} is a register key word"
            labels[label] = address
            # don't output the label line
        else:
            output_code.append(tokens)
            address += 4
    return labels, output_code


def replace_labels(code, labels):
    address = 0
    for i, tokens in enumerate(code):
        if tokens[0] in branch_instructions and tokens[0] != "jalr":
            # have to replace label as relative, jalr does not support labeling
            ref_label = tokens[-1]
            assert ref_label in labels, f"Label `{ref_label}` referenced in line {i}, but not defined in code."
            ref_abs_address = labels[ref_label]
            ref_rel_address = ref_abs_address - address
            tokens[-1] = str(ref_rel_address)
        address += 4
    return code

def replace_instructions(code):
    def get_reg_number(reg_name):
        if reg_name in riscv_reg_translator:
            reg_name = riscv_reg_translator[reg_name]
        assert reg_name.startswith("x")
        try:
            reg_number = int(reg_name[1:])
        except ValueError:
            raise AssertionError(f"Invalid reg name `{reg_name}` in line {i}")
        assert 0 <= reg_number <= 31, f"Invalid reg name `{reg_name}` in line {i}"
        return reg_number

    def get_reg_imm_from_combined_token(combined_token):
        assert "(" in combined_token, f"sw/lw requires combined `<offset>(<rs2>)` as last argument, but got `{combined_token}` in line {i}"
        assert ")" == combined_token[
            -1], f"sw/lw requires combined `<offset>(<rs2>)` as last argument, but got `{combined_token}` in line {i}"
        split_token = combined_token.split("(")
        assert len(
            split_token) == 2, f"sw requires combined `<offset>(<rs2>)` as last argument, but got `{combined_token}` in line {i}"
        imm = get_imm(split_token[0])
        reg = get_reg_number(split_token[1])
        return imm, reg

    def get_imm(token, check_small_range=True):
        try:
            imm = int(token)
        except ValueError:
            raise AssertionError(f"Invalid immediate value `{token}` in line {i}")
        if check_small_range:
            assert -2048 <= imm <= 2047, f"Immediate value {imm} in line {i} must be between -2048 and 2047"
        return imm

    output = []
    for i, tokens in enumerate(code):
        instr = tokens[0]
        assert instr in instruction_translator, f"Invalid instruction `{instr}` in line {i}"
        opcode, add_opcode = instruction_translator[instr]
        if opcode < 20 and add_opcode == 1:
            assert len(tokens) == 4, f"Invalid number of arguments for instruction `{instr}` in line {i}"
            # reg-imm alu op
            machine_code = {
                "opcode": opcode,
                "rd": get_reg_number(tokens[1]),
                "add_opcode": add_opcode,
                "rs1": get_reg_number(tokens[2]),
                "rs2": None,
                "imm": get_imm(tokens[3]),
            }
        elif opcode < 20 and add_opcode == 2:
            assert len(tokens) == 4, f"Invalid number of arguments for instruction `{instr}` in line {i}"
            # reg-reg alu op
            machine_code = {
                "opcode": opcode,
                "rd": get_reg_number(tokens[1]),
                "add_opcode": add_opcode,
                "rs1": get_reg_number(tokens[2]),
                "rs2": get_reg_number(tokens[3]),
                "imm": None,
            }
        elif 20 <= opcode <= 22:
            assert len(tokens) == 3, f"Invalid number of arguments for instruction `{instr}` in line {i}"
            machine_code = {
                "opcode": opcode,
                "rd": get_reg_number(tokens[1]),
                "add_opcode": add_opcode,
                "rs1": None,
                "rs2": None,
                "imm": get_imm(tokens[2], check_small_range=False),
            }
        elif  opcode == 23:
            # jalr rd, imm(rs1)
            assert len(tokens) == 3, f"Invalid number of arguments for instruction `{instr}` in line {i}"
            imm, reg = get_reg_imm_from_combined_token(tokens[2])
            machine_code = {
                "opcode": opcode,
                "rd": get_reg_number(tokens[1]),
                "add_opcode": add_opcode,
                "rs1": reg,
                "rs2": None,
                "imm": imm,
            }
        elif opcode == 24:
            # lw rd, imm(rs1)
            assert len(tokens) == 3, f"Invalid number of arguments for instruction `{instr}` in line {i}"
            combined_token = tokens[2]
            imm, reg = get_reg_imm_from_combined_token(combined_token)
            machine_code = {
                "opcode": opcode,
                "rd": get_reg_number(tokens[1]),
                "add_opcode": add_opcode,
                "rs1": reg,
                "rs2": None,
                "imm": imm,
            }
        elif opcode == 25:
            # sw rs2, imm(rs1)
            assert len(tokens) == 3, f"Invalid number of arguments for instruction `{instr}` in line {i}"
            combined_token = tokens[2]
            imm, reg = get_reg_imm_from_combined_token(combined_token)
            machine_code = {
                "opcode": opcode,
                "rd": None,
                "add_opcode": add_opcode,
                "rs1": reg,
                "rs2": get_reg_number(tokens[1]),
                "imm": imm,
            }
        elif opcode == 26:
            # all branches
            assert len(tokens) == 4, f"Invalid number of arguments for instruction `{instr}` in line {i}"
            machine_code = {
                "opcode": opcode,
                "rd": None,
                "add_opcode": add_opcode,
                "rs1": get_reg_number(tokens[1]),
                "rs2": get_reg_number(tokens[2]),
                "imm": get_imm(tokens[3]),
            }
        elif opcode == 30:
            assert len(tokens) == 1,  f"Invalid number of arguments for instruction `{instr}` in line {i}"
            machine_code = {
                "opcode": opcode,
                "rd": None,
                "add_opcode": add_opcode,
                "rs1": None,
                "rs2": None,
                "imm": None,
            }
        else:
            raise AssertionError(f"Instruction {instr} invalid in line {i}")
        output.append(machine_code)

    return output