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


def encode_int(input_file, bits=7, numbers_per_code=4, new_line_marker=False):
    outputs = []
    with open(input_file, 'r') as file:
        lines = file.readlines()
        for line in lines:
            current_output = 0
            i = 0
            numbers = line.split(" ")
            numbers = [int(n) for n in numbers]
            if new_line_marker:
                numbers.append(2**bits - 1)
            for n in numbers:
                current_output += (n << bits*(numbers_per_code - 1))
                if i < numbers_per_code - 1:
                    current_output = current_output >> bits
                    i += 1
                else:
                    i = 0
                    outputs.append(current_output)
                    current_output = 0
            if current_output != 0:
                current_output = current_output >> (numbers_per_code - i - 1) * bits
                outputs.append(current_output)
    return outputs


def decode_int(outputs, bits=7, numbers_per_code=4, new_line_marker=False):
    result = ""
    for output in outputs:
        for i in range(numbers_per_code):
            n = output % (2**bits)
            output = output >> bits
            if n == 2**bits - 1:
                result += "\n"
                break
            else:
                result += str(n) + " "

    return result
