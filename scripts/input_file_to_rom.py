import json
import string

from bython_compiler.create_blueprint import blueprint_to_json, find_combinator, json_to_blueprint
from bython_compiler.create_machine_code import is_int




def set_drom_values(entity, code):
    filters = entity["control_behavior"]["sections"]["sections"][0]["filters"]
    for filter in filters:
        if filter["name"] == f"signal-D":
            filter["count"] = code
            break

if __name__ == "__main__":
    input_file = "aoc_2024_inputs/01.txt"
    outputs = encode(input_file)
    test = decode(outputs)
    print(test)
    base_bp = "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"
    base_json = blueprint_to_json(base_bp)
    # save json
    with open("temp.json", "w") as file:
        json.dump(base_json, file, indent=4)
    ys = [entity["position"]["y"] for entity in base_json["blueprint"]["entities"]]
    ys.sort()
    xs = [entity["position"]["x"] for entity in base_json["blueprint"]["entities"]]
    xs.sort()
    start_x = -592.5
    start_y = -269.5
    current_x = start_x
    current_y = start_y
    for code in outputs:
        entity = find_combinator(current_x, current_y, base_json)
        set_drom_values(entity, code)
        current_y -= 1
        if current_y < -874.5:
            current_y = start_y
            current_x += 4

    updated_blueprint = json_to_blueprint(base_json)
    with open(input_file[:-4] + ".bp", 'w') as outfile:
        outfile.write(updated_blueprint)
    print("Data Blueprint:")
    print(updated_blueprint)