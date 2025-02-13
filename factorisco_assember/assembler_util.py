from cProfile import label

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
        assert -2**31 <= imm <= 2**31, f"imm value {imm} is bigger than a 32 bit number."
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
        return  i

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

