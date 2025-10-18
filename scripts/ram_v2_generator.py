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
                entity["control_behavior"]["decider_conditions"]["conditions"][1]["constant"] = address + 256
                return base_json
    print(f"No entity found at position {x}, {y}. Skipping address {address}..")
    return base_json

def generate_input_encoding():
    # load text file
    with open("input.txt", "r") as file:
        text = file.read()

def generate_output_filter_combinator():
    base_blueprint = "0eNp9kNFuwjAMRf/Fz2EaqAHaX0GoahNrWGrtKklhqMq/zymT2MPg0b73XN9kgX6YcQrECZoFyAlHaE4LRPribig77kaEBjw68hg2TsaeuEsSIBsg9vgNzTafDSAnSoQPfh3uLc9jj0EN5k2OgUmiosLlnsYd1H5X6PD5YfWIp4DuIVcGtGIKMrQ9XrorKa7Mb2irml+DYtn+nU5LqShzmub04oU3EY+8cReMCXI2/1goyNNwzrlkUsJRpec/GrhiiGtdu9/VVV1ba7fHal/l/ANZDn7b"
    base_json = blueprint_to_json(base_blueprint)
    # save json
    with open("temp.json", "w") as file:
        json.dump(base_json, file, indent=4)
    # load item text file
    with open("output/items.txt", "r") as file:
        items = file.readlines()
        items = [x.strip() for x in items]
    print("stop")


def generate_item_list():
    base_blueprint = "0eNqdmN1u6ygQgN/F12GlnjbVtq9ydBSN8dhmg4EdIGm2yrvv4LRpq2aw1asq5WMGhvn1a9PajIGMS83za2O0d7F5/v3aRDM4sOV/DiZsnpsOtemQlPZTaxwkT8150xjX4UvzfHf+s2nQJZMMXvbPP047l6cWiYFNRc6mCT7yVu+KPhb3+LBpTrzp8emvLSvpDKG+LPMCHzGRt7sWRzgY3s573oTueK2bBcXy38+/fvMBfU4hJ+F+R+87dEqPGFNzPm9uIIZ8HYgJ0S4QnmBAlcDtBSQRuBg8JdWileT0EJNaReJLIIxxHZz5OWkgz38Xta9k3/WvxGOwJiV2mYrmBeZd4wLWZnLsh8ZFJJlaWLbeDWoEvlu3JGk++gLTZrtfYuIE1iq0HBJktAreokBO2Jk8rUJbM6ziYm5jgjkWbwPBBKwsqeTVxQkkKE9BWCIwVo4Z4xQHV22vevtvhdDjLKfGWc+ZyydzkK6pgQavjjCINuptNl2VAErGWqRTlWJNkj3k9BJDyZScQZ14wcHExG5AvvVSmJY6kSjPWbkKgi6mUoH84ZL2K8kxQIyr4fdMWmPa3PcLYgj/zby6RPENS+6shqQF0XWBTBonLFb9XD9vsrcK7W2tc8D6FeT8WuDSMhn8kVXHo0l6lBDyA8E0QWuRcyzCXkxVneEcDCcVwKGV39Ghajnv7OXTa8IkxdsI/wF1aoEi7I3D1dg6oZYTf8+BKh3cmr5XXI6sL34dRZ0BDLGRRAt89Giiy3yOR7a5c+Kj5MDP1+ECdVWpWu/Fc3lj5TqVELj4uIENKiHeAlW9A7TOU7YVj3VZW2QphKBlakRIqlKb5nV84fzvhoUbpUytfKW3rmIyznBn0JHsHddyu4L1fR9HT/xocnksS//IPnSJs56PBxqr/WuduR67jnEqx6m15WIT6JENpu7Wo7/Wo/eSybicX6KZTlJ8jjgZDXYOBbHS8SRDps+DnARayRfYJcUyy5mT88zkuyw3W58Q0SRfIMkY2PdGG3T6VNf4jRPVfifv5XrRlcR04Hmwrv0GKeq/xd6L1VvvkccGY321ZyvpvLhWAKk7jZDQ8lTx7QbpFC6pXJcccx12W4gcKcUV+byahxIWv3IrdAdwmp/2R7u1Z7e2hnubHvStdl3Yx3nwcJpVauJcsl6hNcOYfrKRawA3w30uiYf8pAKW6R55bhkg/lDG9TA/3H+1guAG5VuB2KxAtdOpfVrgBC9KDYGrigxknu7LrCcTBEfVmzjWDsB5MC0coYZcykeVuBpaCmsL8+zRiqNNzJYrj5RxoQz8J/nDQL0TO0IZBFg3iQfUlLl3Kn5exb54cR39iJwq9hGZdWm5tNKl169iFyuyoYGHjQ/0D9PlDU5Iuw6jJhMu3904HXXlo8ruyJMM7t5mlKZ89uPf05ceddMckOK8bfv46+nh6Wm73d79/fD4cD7/D7DtMdU="
    base_json = blueprint_to_json(base_blueprint)
    # save json
    with open("temp.json", "w") as file:
        json.dump(base_json, file, indent=4)
    print("stop")
    output_list = base_json["blueprint"]["entities"][0]["control_behavior"]["decider_conditions"]["outputs"]
    output_list = [output["signal"]["name"] for output in output_list]
    print(output_list)


if __name__ == "__main__":
    # generate_item_list()
    # generate_output_filter_combinator()
    base_blueprint = "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"
    base_json = blueprint_to_json(base_blueprint)
    # save json
    with open("temp.json", "w") as file:
        json.dump(base_json, file, indent=4)
    ys = [entity["position"]["y"] for entity in base_json["blueprint"]["entities"]]
    ys = list(set(ys))
    ys.sort()
    # xs = [entity["position"]["x"] for entity in base_json["blueprint"]["entities"]]
    # xs = list(set(xs))
    # xs.sort()
    # xs = [102, 113, 124, 135, 146, 157]
    xs = [-768]
    address = 82944

    for x in xs:
        for y in ys:
            for sub_x in [0, 2, 4, 6, 8]:
                base_json = change_addresses(base_json, x + sub_x, y, address)
            print(f"changed address {address}")
            address = address + 256

    print(json_to_blueprint(base_json))
    # entities = base_json["blueprint"]["entities"]
    # for entity in entities:
    #     if entity["name"] == "decider-combinator":
    #         print(entity["position"])




