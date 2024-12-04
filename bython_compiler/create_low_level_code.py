import re

FUNCTION_STATE_SIZE = 4

"""
Replaces:
- r1 = r2 if r4 > r5 to CMP(r4, r5); CMOV(r1, r2, <B-Code depending on coparator>)
- label to actual addresses. -> Every line in low level code is one line in the actual CPU
- If/else
- While
- Function calls
"""
from bython_compiler.create_machine_code import is_int


def create_low_level_code(source_code: list[str]):
    # print_code(source_code)
    source_code = remove_comments(source_code)
    # print_code(source_code)
    source_code = function_call_replacement(source_code)
    # print_code(source_code)
    source_code = if_else_replacement(source_code)
    # print_code(source_code)
    source_code = while_replacement(source_code)
    # print_code(source_code)
    source_code = remove_white_space(source_code)
    # print_code(source_code)
    source_code = jump_if_replacement(source_code)
    source_code = cmov_replacement(source_code)
    source_code = label_replacement(source_code)
    # print_code(source_code)
    source_code = optimize_nop(source_code)
    # print_code(source_code)

    return source_code


def optimize_nop(code):
    i = 0
    while i < len(code):
        line = code[i]
        if line.startswith("nop"):
            del code[i]
            for j in range(len(code)):
                if code[j].startswith("jump"):
                    if "," in code[j]:
                        jump_address = code[j][code[j].find("(") + 1: code[j].find(",")].strip()
                    else:
                        jump_address = code[j][code[j].find("(") + 1: code[j].find(")")].strip()
                    if is_int(jump_address) and int(jump_address) > i:
                        new_jump_address = str(int(jump_address) - 1)
                        if "," in code[j]:
                            code[j] = code[j][:code[j].find("(") + 1] + new_jump_address + code[j][code[j].find(","):]
                        else:
                            code[j] = code[j][:code[j].find("(") + 1] + new_jump_address + code[j][code[j].find(")"):]
            i = 0
        else:
            i += 1
    return code


def function_call_replacement(code: list[str]):
    # gather all functions used
    functions = {}
    for line in code:
        if line.startswith("def "):
            func = line[line.find("def ") + 3:line.find("(")].strip()
            assert func not in functions, f"Function name {func} used multiple times."
            params = line[line.find("(") + 1:line.find(")")].split(",")
            params = [x.strip() for x in params]
            if params == [""]:
                params = []
            functions[func] = params
    # replace calls
    i = 0
    while i < len(code):
        line = code[i]
        start_again = False
        for func in functions:
            if "def" not in line and func + "(" in line:
                # replace it with:
                # push(r1)
                # push(r2)
                # push(r3)
                # push(r_{function_state_size})
                # r13 = pc + 4  # 3 + number of args
                # push(r13)
                # # arguments
                # push(r1)
                # jump(func)
                indent = get_indent(line)
                # TODO: catch labels here!!
                return_reg = line.split("=")[0].strip()
                args = line[line.find("(") + 1:line.find(")")].split(",")
                args = [x.strip() for x in args]
                if args == [""]:
                    args = []
                assert len(args) == len(
                    functions[func]), f"Line {i}: Number of given arguments does not match function definition"
                del code[i]
                for s in range(FUNCTION_STATE_SIZE):
                    code.insert(i + s, " " * indent + f"push(r{s + 1})")

                code.insert(i + FUNCTION_STATE_SIZE, " " * indent + f"r13 = pc + {3 + len(args)}")
                code.insert(i + FUNCTION_STATE_SIZE + 1, " " * indent + "push(r13)")
                for i_arg, arg in enumerate(args):
                    code.insert(i + FUNCTION_STATE_SIZE + 2 + i_arg, " " * indent + f"push({arg})")
                code.insert(i + FUNCTION_STATE_SIZE + 2 + len(args), " " * indent + f"jump({func})")
                code.insert(i + FUNCTION_STATE_SIZE + 3 + len(args), " " * indent + f"{return_reg} = pop()")
                start_again = True
                break
        if start_again:
            i = 0
        else:
            i += 1

    # replace bodies
    i = 0
    while i < len(code):
        line = code[i]
        start_again = False
        for func in functions:
            if line.startswith(f"def {func}"):
                code[i] = f"&{func} nop"
                assert get_indent(code[i + 1]) == 4
                j = i + 1
                # insert args, reversed since stack
                for p in reversed(functions[func]):
                    code.insert(j, f"{p} = pop()")
                    j += 1
                while j < len(code) and get_indent(code[j]) >= 4:
                    # indent 4 to the left
                    code[j] = code[j][4:]
                    # check return
                    if code[j].strip().startswith("return"):
                        # return statement, save it in r12, get jump back address, create initial state
                        return_reg = code[j][code[j].find("return") + 6:].strip()
                        return_indent = get_indent(code[j])
                        code[j] = " " * return_indent + f"r12 = {return_reg}"
                        # jump back address
                        code.insert(j + 1, " " * return_indent + f"r13 = pop()")
                        j += 1
                        # state
                        for s in reversed(range(FUNCTION_STATE_SIZE)):
                            code.insert(j + 1, " " * return_indent + f"r{s + 1} = pop()")
                            j += 1
                        # push return
                        code.insert(j + 1, " " * return_indent + f"push(r12)")
                        j += 1
                        code.insert(j + 1, " " * return_indent + f"jump(r13)")
                        j += 1
                    j += 1
                start_again = True
                break
        if start_again:
            i = 0
        else:
            i += 1

    return code


def if_else_replacement(code: list[str]):
    if_counter = 0
    i = 0
    while i < len(code):
        cleaned_line, labels, line = clean_line_extract_labels(code, i)
        if cleaned_line.strip().startswith("if"):
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
                # label next line with else label
                assert get_indent(code[j + 1]) == indent + 4, "Else block not correct"
                else_label = f"else_{if_counter}"
                end_if_label = f"end_if_{if_counter}"
                code[j + 1] = insert_label(code[j + 1], else_label)
                # replace else statement with jump to end if
                code[j] = " " * indent + f"jump({end_if_label})"
                j = j + 1
                # else block
                while get_indent(code[j]) > indent:
                    # in else block, remove 1 indent level, since we resolve this else clause
                    code[j] = code[j][4:]
                    j += 1
                    if j == len(code):
                        # reached end of file
                        break
                if j == len(code):
                    code.append("&" + end_if_label + " nop")
                else:
                    # check if line j is less indent then line i. if thats the case
                    # we have to insert nop since we would jump out of another block
                    code.insert(j, insert_label(" " * indent + "nop", end_if_label))
                if_counter += 1
                # replace if statement
                condition = line[line.find("if"):line.find(":")][2:].strip()
                cmp_cmd, antiflag = get_cmp_and_flag(condition, antiflag=True)
                code[i] = " " * indent + labels + cmp_cmd
                code.insert(i + 1, " " * indent + f"jump({else_label}, {antiflag})")
                i = 0
            else:
                # if case, label line j
                label = f"end_if_{if_counter}"
                if j == len(code):
                    code.append("&" + label + " nop")
                else:
                    code.insert(j, insert_label(" " * indent + "nop", label))
                if_counter += 1
                # replace if statement
                condition = line[line.find("if"):line.find(":")][2:].strip()
                cmp_cmd, antiflag = get_cmp_and_flag(condition, antiflag=True)
                code[i] = " " * indent + labels + cmp_cmd
                code.insert(i + 1, " " * indent + f"jump({label}, {antiflag})")
                i = 0
        else:
            i += 1
    return code


def clean_line_extract_labels(code, i):
    line = code[i]
    labels = []
    cleaned_line = line.strip()
    while cleaned_line.startswith("&"):
        new_label, cleaned_line = cleaned_line.split(" ", maxsplit=1)
        cleaned_line = cleaned_line.strip()
        labels.append(new_label)
    labels = " ".join(labels)
    if labels != "":
        labels += " "
    return cleaned_line, labels, line


def while_replacement(code):
    while_counter = 0
    i = 0
    while i < len(code):
        cleaned_line, labels, line = clean_line_extract_labels(code, i)
        if cleaned_line.strip().startswith("while"):
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
            end_label = f"end_while_{while_counter}"
            start_label = f"start_while_{while_counter}"
            if j == len(code):
                code.append("&" + end_label + " nop")
            else:
                code.insert(j, insert_label(" " * indent + "nop", end_label))
            while_counter += 1
            # replace while statement
            condition = line[line.find("while"): line.find(":")][5:].strip()
            cmp_cmd, antiflag = get_cmp_and_flag(condition, antiflag=True)
            code[i] = " " * indent + labels + f"&{start_label} " + cmp_cmd
            code.insert(i + 1, " " * indent + f"jump({end_label}, {antiflag})")
            code.insert(j + 1, " " * indent + f"jump({start_label})")
            i = 0
        else:
            i += 1
    return code


def jump_if_replacement(code):
    return code


def cmov_replacement(code):
    # replaces stuff like r1 = r2 if r3 < r4
    i = 0
    while i < len(code):
        cleaned_line, labels, line = clean_line_extract_labels(code, i)
        match = re.search(r'(?<![<>=])=(?![<>=])', cleaned_line)
        if match:
            left_side, right_side = cleaned_line[:match.start()].strip(), cleaned_line[match.start() + 1:]
            # test if "if" in right side:
            if "if" in right_side:
                # cmov
                body, condition = right_side.split("if", maxsplit=1)
                condition = condition.strip()
                body = body.strip()
                cmp_command, flag = get_cmp_and_flag(condition, antiflag=False)
                indent = get_indent(line)
                del code[i]
                code.insert(i, " " * indent + labels + cmp_command)
                code.insert(i + 1, " " * indent + f"{left_side} = cmov({body}, {flag})")
                i = 0
            else:
                i += 1
                continue
        else:
            i += 1
    return code


def insert_label(line, label):
    assert not label.startswith("&")
    # find first char which is not whitespace
    start_index = len(line) - len(line.lstrip())
    output = line[:start_index] + "&" + label.strip() + " " + line[start_index:]
    return output


def label_replacement(code):
    label_dict = {}
    for i, line in enumerate(code):
        while code[i].strip().startswith("&"):
            label, rest_line = code[i].split(" ", maxsplit=1)
            label = label.strip()[1:]
            label_dict[label] = i
            code[i] = rest_line

    for i, line in enumerate(code):
        if line.strip().startswith("jump"):
            if "," in line:
                label_or_op = line[line.find("(") + 1:line.find(",")]
            else:
                label_or_op = line[line.find("(") + 1:line.find(")")].strip()
            assert not label_or_op.startswith(
                "&"), f"Line {i}; Don't write the '&' before the label when using it in a jump command"
            if label_or_op in label_dict:
                if "," in line:
                    code[i] = line[:line.find("(") + 1] + str(label_dict[label_or_op]) + line[line.find(","):]
                else:
                    code[i] = line[:line.find("(") + 1] + str(label_dict[label_or_op]) + line[line.find(")"):]
    return code


def get_cmp_and_flag(condition, antiflag=True):
    # split condition
    if antiflag:
        comparators = {"==": 2, "!=": 1, ">=": 5, "<=": 3, ">": 6, "<": 4}
    else:
        comparators = {"==": 1, "!=": 2, ">=": 4, "<=": 6, ">": 3, "<": 5}
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
    relevant_lines = [i for i in range(len(code)) if code[i].strip() != ""]
    code = [line for i, line in enumerate(code) if i in relevant_lines]
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
        print(f"[{i:03d}] " + line)
    print("-------------------------")
