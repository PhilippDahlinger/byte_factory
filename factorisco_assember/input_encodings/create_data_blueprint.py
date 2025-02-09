import json

from bython_compiler.create_blueprint import blueprint_to_json, find_combinator, json_to_blueprint


def change_pmem(base_json, x, y, code):
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


def create_data_blueprint(outputs, output_file):
    base_bp = "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"
    base_json = blueprint_to_json(base_bp)
    # save json
    with open("temp.json", "w") as file:
        json.dump(base_json, file, indent=4)
    ys = list(set([entity["position"]["y"] for entity in base_json["blueprint"]["entities"]]))
    ys.sort()
    xs = list(set([entity["position"]["x"] for entity in base_json["blueprint"]["entities"]]))
    xs.sort()
    code_address = 0
    for x in xs:
        for y in ys:
            base_json = change_pmem(base_json, x, y, outputs[code_address])
            code_address += 1
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
