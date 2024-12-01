import json

from bython_compiler.create_blueprint import blueprint_to_json, json_to_blueprint


def change_addresses(base_json, start_address=0):
    entities = base_json["blueprint"]["entities"]

    start_y = -269.5
    for y in range(573):
        current_y = start_y - y
        for entity in entities:
            if entity["name"] == "decider-combinator":
                pos = entity["position"]
                if pos["y"] == current_y:
                    # change address to y + start_address
                    entity["control_behavior"]["decider_conditions"]["conditions"][1]["constant"] = y + start_address

    return base_json


if __name__ == "__main__":
    base_blueprint = "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"
    base_json = blueprint_to_json(base_blueprint)
    # save json
    with open("temp.json", "w") as file:
        json.dump(base_json, file, indent=4)
    ys = [entity["position"]["y"] for entity in base_json["blueprint"]["entities"]]
    ys.sort()
    print(ys[0], ys[-1])
    for start_address in [1, 1 + 573, 1 + 2 * 573, 1 + 3 * 573]:
        updated_json = change_addresses(base_json, start_address=start_address)
        print(f"start_address {start_address}:")
        print(json_to_blueprint(updated_json))
    # entities = base_json["blueprint"]["entities"]
    # for entity in entities:
    #     if entity["name"] == "decider-combinator":
    #         print(entity["position"])
