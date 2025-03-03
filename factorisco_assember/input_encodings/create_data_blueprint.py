import json

from bython_compiler.create_blueprint import blueprint_to_json, find_combinator, json_to_blueprint
from scripts.get_signal_dict import signal_dict


def change_pmem_v1(base_json, x, y, code):
    entities = base_json["blueprint"]["entities"]
    for entity in entities:
        if entity["name"] == "constant-combinator":
            pos = entity["position"]
            if pos["y"] == y and pos["x"] == x:
                # change address
                entity["control_behavior"]["sections"]["sections"][0]["filters"][0]["count"] = code
                return base_json
    print(f"No entity found at position {x}, {y}. Skipping code {code}..")
    return base_json


def change_pmem_v2(base_json, x, y, line_idx, code):
    entities = base_json["blueprint"]["entities"]
    for entity in entities:
        if entity["name"] == "constant-combinator":
            pos = entity["position"]
            if pos["y"] == y and pos["x"] == x:
                # change address
                entity["control_behavior"]["sections"]["sections"][0]["filters"][line_idx]["count"] = code
                return base_json
    print(f"No entity found at position {x}, {y}. Skipping code {code}..")
    return base_json

def create_data_blueprint(outputs, output_file, output_version="v2"):
    if output_version == "v1":
        base_bp = "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"
        base_json = blueprint_to_json(base_bp)
    elif output_version == "v2":
        base_bp = "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"
        base_json = blueprint_to_json(base_bp)
    else:
        raise ValueError(f"Invalid output version: {output_version}")
    ys = list(set([entity["position"]["y"] for entity in base_json["blueprint"]["entities"]]))
    ys.sort()
    xs = list(set([entity["position"]["x"] for entity in base_json["blueprint"]["entities"]]))
    xs.sort()
    code_address = 0
    lines_per_combinator = 1 if output_version == "v1" else 256
    with open("output/signal_dict.json", "r") as f:
        signal_dict = json.load(f)
    for x in xs:
        for y in ys:
            for line_idx in range(lines_per_combinator):
                if output_version == "v1":
                    base_json = change_pmem_v1(base_json, x, y, outputs[code_address])
                else:
                    base_json = change_pmem_v2(base_json, x, y, line_idx, outputs[code_address])
                code_address += 1
                if code_address >= len(outputs):
                    break
            if code_address >= len(outputs):
                break
        if code_address >= len(outputs):
            break
    updated_blueprint = json_to_blueprint(base_json)
    with open(output_file, 'w') as outfile:
        outfile.write(updated_blueprint)
    print("Data Blueprint:")
    print(updated_blueprint)


if __name__ == "__main__":
    outputs = [23, 25, 27]
    create_data_blueprint(outputs, output_file="output/factorisco/debug_1.txt")
