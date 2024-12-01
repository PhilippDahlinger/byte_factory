import json
import string

from bython_compiler.create_blueprint import blueprint_to_json, find_combinator, json_to_blueprint
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


def set_drom_values(entity, code):
    filters = entity["control_behavior"]["sections"]["sections"][0]["filters"]
    for filter in filters:
        if filter["name"] == f"signal-D":
            filter["count"] = code
            break

if __name__ == "__main__":
    input_file = "aoc_2024_inputs/01_test.txt"
    outputs = encode(input_file)
    base_bp = "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"
    base_json = blueprint_to_json(base_bp)
    # save json
    with open("temp.json", "w") as file:
        json.dump(base_json, file, indent=4)
    # ys = [entity["position"]["y"] for entity in base_json["blueprint"]["entities"]]
    # ys.sort()
    # xs = [entity["position"]["x"] for entity in base_json["blueprint"]["entities"]]
    # xs.sort()
    start_x = -592.5
    start_y = -269.5
    current_x = start_x
    current_y = start_y
    for code in outputs:
        entity = find_combinator(current_x, current_y, base_json)
        set_drom_values(entity, code)
        current_y -= 1
        if current_y < -396.5:
            current_y = start_y
            current_x += 4

    updated_blueprint = json_to_blueprint(base_json)
    with open(input_file[:-4] + ".bp", 'w') as outfile:
        outfile.write(updated_blueprint)