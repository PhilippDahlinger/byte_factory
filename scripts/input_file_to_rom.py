import string

from bython_compiler.create_machine_code import is_int


def get_encoding(char, bits=4):
    if bits == 4:
        if is_int(char):
            return int(char)
        if char == " ":
            return 10
        if char == "\n":
            return 11
        if char == ",":
            return 12
        if char == ".":
            return 13
        if char == "endoffile":
            return 15
        # wildcard
        return 14
    else:
        raise NotImplementedError()

def get_decoding(code, bits=4):
    if bits == 4:
        if 0 <= code < 10:
            return str(code)
        if code == 10:
            return " "
        if code == 11:
            return "\n"
        if code == 12:
            return ","
        if code == 13:
            return "."
        if code == 15:
            return "endoffile"
        # wildcard
        if code == 14:
            return "*"
        raise ValueError(code)
    else:
        raise NotImplementedError()


def encode(input_file):
    with open(input_file, 'r') as file:
        # Read the file's content
        content = list(file.read())

    # Iterate over each character in the file
    i = 0
    outputs = []
    current_output = 0
    for char in content:
        current_output += (get_encoding(char) << 24)
        if i < 6:
            current_output = current_output >> 4
            i += 1
        else:
            i = 0
            outputs.append(current_output)
            current_output = 0
    current_output += get_encoding("endoffile")
    outputs.append(current_output)
    return outputs


def decode(outputs):
    result = ""
    for output in outputs:
        for i in range(7):
            current_code = output % 16
            output = output >> 4
            char = get_decoding(current_code, bits=4)
            if char == "endoffile":
                return result
            result += char
    return result


if __name__ == "__main__":
    input_file = "aoc_2024_inputs/01_test.txt"
    outputs = encode(input_file)
    print(outputs)
    print(decode(outputs))
    print("stop")