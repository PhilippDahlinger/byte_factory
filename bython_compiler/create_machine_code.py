REG_ADDRESSES = {"pc": 15}
REG_ADDRESSES.update({f"r{i}": i for i in range(1, 14)})


def create_machine_code(code: list[str]):
    """
    Expects that the code is already low-level.
    :param code:
    :return:
    """
    machine_code = []
    for i, line in enumerate(code):
        machine_line = {"C": 0, "0": 0, "1": 0, "2": 0, "I": 0}
        if "=" in line:
            # TODO check for comparisons like "==", "<=", ...
            left_side = line.split("=", 1)[0].strip().lower()
            right_side = line.split("=", 1)[1].strip().lower()
            # register write back
            if left_side in REG_ADDRESSES.keys():
                machine_line["0"] = REG_ADDRESSES[left_side]
            # all other places to store something
            elif left_side.startswith("mem"):
                machine_line["C"] = 19
                machine_line["1"], machine_line["I"] = parse_address(left_side)
                parse_op_b(right_side, machine_line)

            elif left_side.startswith("disp"):
                machine_line["C"] = 26
                machine_line["1"], machine_line["I"] = parse_address(left_side)
                parse_op_b(right_side, machine_line)
            else:
                raise AssertionError(f"Line {i + 1}: Left side {left_side} is wrong")
            if left_side in REG_ADDRESSES.keys():
                resolved = False
                # MOV
                if right_side in REG_ADDRESSES:
                    machine_line["C"] = 1
                    machine_line["1"] = REG_ADDRESSES[right_side]
                    resolved = True
                elif is_int(right_side):
                    machine_line["C"] = 1
                    machine_line["1"] = 14  # IMM
                    machine_line["I"] = int(right_side)
                    resolved = True

                # ALU
                # basic alu ops
                concatenate_symbols = ["+", "-", "*", "/", "%", "**", "place_holder", "place_holder", "&", "|", "^",
                                       "<<", ">>"]
                for c_s in concatenate_symbols:
                    if c_s in right_side:
                        if c_s == "*" and "**" in right_side:
                            # it's actually power, not mult
                            continue
                        first_op, second_op = [x.strip() for x in right_side.split(c_s)]
                        parse_two_ops(first_op, second_op, machine_line)
                        # determine opcode
                        c_s_index = concatenate_symbols.index(c_s)
                        machine_line["C"] = c_s_index + 2
                        resolved = True
                        break
                # min and max
                if "min" in right_side or "max" in right_side:
                    args = right_side[right_side.find("(") + 1: right_side.rfind(")")]
                    first_op, second_op = [x.strip() for x in args.split(",")]
                    parse_two_ops(first_op, second_op, machine_line)
                    resolved = True
                if "min" in right_side:
                    machine_line["C"] = 8
                if "max" in right_side:
                    machine_line["C"] = 9

                # LOAD
                if "mem" in right_side:
                    machine_line["C"] = 18
                    machine_line["1"], machine_line["I"] = parse_address(right_side)
                elif right_side.startswith("int_user"):
                    machine_line["C"] = 23
                    machine_line["1"], machine_line["I"] = parse_address(right_side)
                elif right_side.startswith("user"):
                    machine_line["C"] = 24
                    machine_line["1"], machine_line["I"] = parse_address(right_side)
                elif "rom" in right_side:
                    machine_line["C"] = 22
                    machine_line["1"], machine_line["I"] = parse_address(right_side)
                elif "pop" in right_side:
                    machine_line["C"] = 21
                elif "random" in right_side:
                    raise NotImplementedError()
                elif "cmov" in right_side:
                    machine_line["C"] = 15
                    args = line[line.find("(") + 1: line.rfind(")")]
                    first_op, second_op = [x.strip() for x in args.split(",")]
                    parse_op_a(first_op, machine_line)
                    assert is_int(second_op), f"Line{i}: Second Operator has to be numeric"
                    machine_line["2"] = int(second_op)
                    # parse_two_ops(first_op, second_op, machine_line)
                else:
                    if not resolved:
                        raise AssertionError(f"Line {i + 1}: Right side {right_side} is wrong")
        else:
            # no "=" in line
            if "nop" in line:
                # do nothing
                pass
            elif "push" in line:
                machine_line["C"] = 20
                op = line[line.find("(") + 1:line.rfind(")")]
                parse_op_b(op, machine_line)
            elif "clear_disp" in line:
                machine_line["C"] = 27
            elif "exit" in line:
                machine_line["C"] = 31
                # TODO: Error halt
            elif "jump" in line:
                machine_line["0"] = 15
                if "," in line:
                    # conditional jump
                    machine_line["C"] = 15
                    args = line[line.find("(") + 1: line.rfind(")")]
                    first_op, second_op = [x.strip() for x in args.split(",")]
                    parse_op_a(first_op, machine_line)
                    assert is_int(second_op), f"Line{i}: Second Operator has to be numeric"
                    machine_line["2"] = int(second_op)
                else:
                    # unconditional jump
                    machine_line["C"] = 1
                    op = line[line.find("(") + 1:line.rfind(")")]
                    parse_op_a(op, machine_line)
            elif "cmp" in line:
                machine_line["C"] = 16
                args = line[line.find("(") + 1: line.rfind(")")]
                first_op, second_op = [x.strip() for x in args.split(",")]
                parse_two_ops(first_op, second_op, machine_line)
        machine_code.append(machine_line)

    machine_code_str = []
    for line in machine_code:
        machine_code_str.append(f"C={line["C"]},0={line["0"]},1={line["1"]},2={line["2"]},I={line["I"]}")
    return machine_code, machine_code_str


def parse_two_ops(first_op, second_op, machine_line):
    parse_op_a(first_op, machine_line)
    parse_op_b(second_op, machine_line)


def parse_op_a(op, machine_line):
    if op in REG_ADDRESSES:
        machine_line["1"] = REG_ADDRESSES[op]
    elif is_int(op):
        machine_line["1"] = 14  # IMM
        machine_line["I"] = int(op)
    else:
        raise AssertionError(f"Error on line {machine_line} parsing {op}")


def parse_op_b(op, machine_line):
    if op in REG_ADDRESSES:
        machine_line["2"] = REG_ADDRESSES[op]
    elif is_int(op):
        machine_line["2"] = 14  # IMM
        machine_line["I"] = int(op)
    else:
        raise AssertionError(f"Error on line {machine_line} parsing {op}")


def parse_address(complete_term):
    address = complete_term[complete_term.find("[") + 1: complete_term.rfind("]")]
    if "+" in address:
        reg, imm = address.split("+")
        reg_address = REG_ADDRESSES[reg]
        imm = int(imm)
    elif "-" in address:
        reg, imm = address.split("-")
        reg_address = REG_ADDRESSES[reg]
        imm = -int(imm)
    else:
        if is_int(address):
            imm = int(address)
            reg_address = 0
        else:
            reg_address = REG_ADDRESSES[address]
            imm = 0
    return reg_address, imm


def is_int(string):
    try:
        int(string)
        return True
    except ValueError:
        return False
