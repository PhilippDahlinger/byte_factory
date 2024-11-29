

"""
Replaces:
- r1 = r2 if r4 > r5 to CMP(r4, r5); CMOV(r1, r2, <B-Code depending on coparator>)
- label to actual addresses. -> Every line in low level code is one line in the actual CPU
- If/else
- While
- Function calls
"""


def while_replacement(code):
    return code


def jump_if_replacement(code):
    return code


def cmov_replacement(code):
    return code




def create_low_level_code(source_code: list[str]):
    # print_code(source_code)
    source_code = remove_comments(source_code)
    # print_code(source_code)
    source_code = if_else_replacement(source_code)
    # print_code(source_code)
    source_code = while_replacement(source_code)
    source_code = remove_white_space(source_code)
    # print_code(source_code)
    source_code = jump_if_replacement(source_code)
    source_code = cmov_replacement(source_code)
    source_code = label_replacement(source_code)
    # print_code(source_code)

    return source_code

def if_else_replacement(code: list[str]):
    if_counter = 0
    i = 0
    while i < len(code):
        line = code[i]
        if line.strip().startswith("if"):
            indent = get_indent(line)
            assert get_indent(code[i + 1]) == indent + 4
            j = i + 1
            while get_indent(code[j]) > indent:
                # in if block, remove 1 indent level, since we resolve this if clause
                code[j] = code[j][4:]
                j += 1
                if j == len(code):
                    # reached end of file
                    break
            if code[j].startswith(" " * indent + "else:"):
                # if-else case
                raise NotImplementedError()
            else:
                # if case, label line j
                label = f"end_if_{if_counter}"
                if j == len(code):
                    code.append("&" + label + " nop")
                else:
                    code[j] = "&" + label + " " + code[j]
                if_counter += 1
                # replace if statement
                condition = line.strip()[2:-1].strip()
                cmp_cmd, antiflag = get_cmp_and_flag(condition, antiflag=True)
                code[i] = " " * indent + cmp_cmd
                code.insert(i + 1, " " * indent + f"jump({label}, {antiflag})")
                i = 0
        else:
            i += 1
    return code


def label_replacement(code):
    label_dict = {}
    for i, line in enumerate(code):
        while code[i].strip().startswith("&"):
            label, rest_line = line.split(" ", maxsplit=1)
            label = label.strip()[1:]
            label_dict[label] = i
            code[i] = rest_line

    for i, line in enumerate(code):
        if line.strip().startswith("jump"):
            if "," in line:
                label_or_op = line[line.find("(") + 1:line.find(",")]
            else:
                label_or_op = line[line.find("(") + 1:line.find(")")].strip()
            assert not label_or_op.startswith("&"), f"Line {i}; Don't write the '&' before the label when using it in a jump command"
            if label_or_op in label_dict:
                if "," in line:
                    code[i] = line[:line.find("(") + 1] + str(label_dict[label_or_op]) + line[line.find(","):]
                else:
                    code[i] = line[:line.find("(") + 1] + str(label_dict[label_or_op]) + line[line.find(")"):]
    return code


def get_cmp_and_flag(condition, antiflag=True):
    # split condition
    if antiflag:
        comparators = {"==": 2, "!=": 1, ">": 6, ">=": 5, "<": 4, "<=": 3}
    else:
        comparators = {"==": 1, "!=": 2, ">": 3, ">=": 4, "<": 5, "<=": 6}
    for c in comparators.keys():
        if c in condition:
            r1, r2 = condition.split(c, maxsplit=1)
            cmp_command = f"cmp({r1},{r2})"
            flag = comparators[c]
            return cmp_command, flag


def get_indent(line):
    return len(line) - len(line.lstrip(' '))

def remove_comments(code: list[str]):
    code = [line.split("#", 1)[0] for line in code]
    return code

def remove_white_space(code):
    # Strip leading and trailing whitespace
    code = [line.strip() for line in code]
    relevant_lines = [i for i in range(len(code)) if code[i] != ""]
    code = [line for i, line in enumerate(code) if i in relevant_lines]
    return code

def print_code(code):
    print("-------------------------")
    for i, line in enumerate(code):
        print(f"[{i}] " + line)
    print("-------------------------")
