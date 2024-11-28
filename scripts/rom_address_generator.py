import json

from scripts.ram_address_generator import blueprint_to_json, json_to_blueprint


def change_addresses(base_json, start_address=0):
    entities = base_json["blueprint"]["entities"]

    start_y = -269.5
    for y in range(128):
        current_y = start_y - y
        for entity in entities:
            if entity["name"] == "decider-combinator":
                pos = entity["position"]
                if pos["y"] == current_y:
                    # change address to y + start_address
                    entity["control_behavior"]["decider_conditions"]["conditions"][0]["constant"] = y + start_address

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
    for start_address in [1, 129, 257, 256+129]:
        updated_json = change_addresses(base_json, start_address=start_address)
        print(f"start_address {start_address}:")
        print(json_to_blueprint(updated_json))
    # entities = base_json["blueprint"]["entities"]
    # for entity in entities:
    #     if entity["name"] == "decider-combinator":
    #         print(entity["position"])
