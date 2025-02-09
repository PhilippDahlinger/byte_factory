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
