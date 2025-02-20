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
