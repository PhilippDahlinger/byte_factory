import json

from bython_compiler.create_blueprint import blueprint_to_json, json_to_blueprint



if __name__ == "__main__":
    # generate_item_list()
    # generate_output_filter_combinator()
    base_blueprint = "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"
    # base_blueprint = "0eNqlUl1q3EAMvorRUwqTUBt7yfqxDz1B35JgZm3trog9M2jkTcziA/QgvVhOUo2dJqGFBNKXAUmj70fSGXb9iIHJCdRnoNa7CPXNGSIdnO1TztkBoYYOW+qQL1s/7MhZ8QyzAXIdPkKdz3cG0AkJ4dq/BFPjxmGHrB/MOzgGgo/a6l3iS3BfNwYmqDfXV5WSdMTYruXSgEoU9n2zw6M9kbZrzzNoo7VuAYop+zZSSXviKM2rMZlCEnQillEzLwrXH5dl8pfmITYNp6hU01uIxqE8eL5fqBg7qIVHNHBgRFW6t33EeTb/y1vlRQqHYHkZVg1PP3/BZ6ToivwoYZS/N/yBIDwhT3Ikd0jK/qFa0F+4ErFSqXEIvZ10Jx3Glims+4Mi+0Htffa9p6CPD7fu2yjZ3nOWZ5IqcsSss2KzlT3TQ0KOS/p5838qFwvlF0jGHvREkq2b3BQmN+Wd5khwUMbXAzegTuKio9oU23K7raoqvy435Tz/BukPDZs="
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
    # xs = [102, 113, 124, 135, 146, 157]
    # address = 256
    for entity in base_json["blueprint"]["entities"]:
        entity["control_behavior"]["decider_conditions"]["conditions"][1]["comparator"] = '≥'


    print(json_to_blueprint(base_json))
    # entities = base_json["blueprint"]["entities"]
    # for entity in entities:
    #     if entity["name"] == "decider-combinator":
    #         print(entity["position"])




