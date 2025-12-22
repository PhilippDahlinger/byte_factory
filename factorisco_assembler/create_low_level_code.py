
def remove_comments(code: list[str]):
    line_labels = list(range(1, len(code) + 1))
    code = [line.split("#", 1)[0] for line in code]
    relevant_lines = [i for i in range(len(code)) if code[i].strip() != ""]
    code = [line for i, line in enumerate(code) if i in relevant_lines]
    line_labels = [ll for i, ll in enumerate(line_labels) if i in relevant_lines]
    return code, line_labels


def remove_white_space(code, line_labels):
    # Strip leading and trailing whitespace
    code = [line.strip() for line in code]
    relevant_lines = [i for i in range(len(code)) if code[i] != ""]
    code = [line for i, line in enumerate(code) if i in relevant_lines]
    line_labels = [ll for i, ll in enumerate(line_labels) if i in relevant_lines]
    return code, line_labels


def print_code(code):
    print("-------------------------")
    for i, line in enumerate(code):
        print(f"[{i:03d}] " + line)
    print("-------------------------")
