import base64
import json
import zlib


def blueprint_to_json(string):
    data = zlib.decompress(base64.b64decode(string[1:]))
    return json.loads(data)


def json_to_blueprint(json_data):
    compressed = zlib.compress(json.dumps(json_data).encode('utf-8'), level=9)
    return '0' + base64.b64encode(compressed).decode('utf-8')

def find_combinator(x, y, base_json):
    entities = base_json["blueprint"]["entities"]
    for entity in entities:
        pos = entity["position"]
        if pos["y"] == y and pos["x"] == x:
            return entity
    raise ValueError(f"No combinator found on pos {x}, {y}.")

def set_values(entity, line):
    filters = entity["control_behavior"]["sections"]["sections"][0]["filters"]
    for signal, value in line.items():
        for filter in filters:
            if filter["name"] == f"signal-{signal}":
                filter["count"] = value
                break


def create_blueprint(machine_code):
    assert len(machine_code) <= 512, "Machine Code is too long!"
    base_blueprint = "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"
    # base_blueprint = "0eNqdks1ugzAMx9/F51ANSmAg7bTTnqGqqkCzzRI4LARUhPLuc0DrtB2GhnJx/nZ+/ohnqJpBdxbJQTkD1oZ6KE8z9PhGqgkaqVZDCcHjFLmoNm2FpJyx4AUgXfUNytifBWhy6FCvgOUyXWhoK205QPwFEtCZnt8aChmZF2WP8UEKmNhMMnmQnOqKVtdrTJyIwHHWNJdKv6sRGcIv+zWg/2lzNV9lCnjFxmn7W3VTF2ob0bqB274Xu44hemblgx3cEYtkbLsEcQedsksHJTwtwhAGGXtxhyeb8If98OMmPN4PTzfhyX643IS//Bd+5uPDHqLTLTu/N1vAyF++bI7MkiItCpnmRS7zo/efQ/r9Pw=="
    base_json = blueprint_to_json(base_blueprint)
    # save json
    with open("temp.json", "w") as file:
        json.dump(base_json, file, indent=4)
    start_x = -681.5
    start_y = -265.5
    current_x = start_x
    current_y = start_y
    for line in machine_code:
        entity = find_combinator(current_x, current_y, base_json)
        set_values(entity, line)
        current_y -= 1
        if current_y < -392.5:
            current_y = start_y
            current_x += 4

    updated_blueprint = json_to_blueprint(base_json)

    # ys = [entity["position"]["y"] for entity in base_json["blueprint"]["entities"]]
    # ys.sort()
    # xs = [entity["position"]["x"] for entity in base_json["blueprint"]["entities"]]
    # xs.sort()
    # print("stop")
    return updated_blueprint
