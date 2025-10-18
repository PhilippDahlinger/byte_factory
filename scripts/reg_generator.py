import json

from bython_compiler.create_blueprint import blueprint_to_json, json_to_blueprint


def change_addresses(base_json, x, y, address):
    entities = base_json["blueprint"]["entities"]
    for entity in entities:
        if entity["name"] == "decider-combinator":
            pos = entity["position"]
            if pos["y"] == y and pos["x"] == x:
                # change address
                entity["control_behavior"]["decider_conditions"]["conditions"][0]["constant"] = address
                return base_json
    print(f"No entity found at position {x}, {y}. Skipping address {address}..")
    return base_json


if __name__ == "__main__":
    base_blueprint = "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"
    base_json = blueprint_to_json(base_blueprint)
    # save json
    with open("temp.json", "w") as file:
        json.dump(base_json, file, indent=4)
    ys = [entity["position"]["y"] for entity in base_json["blueprint"]["entities"]]
    ys = list(set(ys))
    ys.sort()
    xs = [entity["position"]["x"] for entity in base_json["blueprint"]["entities"]]
    xs = list(set(xs))
    xs.sort()
    address = 1
    # iterate over rows
    for y in ys:
        for x in xs:
            base_json = change_addresses(base_json, x, y, address)
            print(f"changed address {address}")
        address = address + 1

    print(json_to_blueprint(base_json))
    # entities = base_json["blueprint"]["entities"]
    # for entity in entities:
    #     if entity["name"] == "decider-combinator":
    #         print(entity["position"])
