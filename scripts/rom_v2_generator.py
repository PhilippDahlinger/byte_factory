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
    xs = [entity["position"]["x"] for entity in base_json["blueprint"]["entities"]]
    xs = list(set(xs))
    xs.sort()
    xs = [57]
    address = 160256

    for x in xs:
        for y in ys:
            for sub_x in [0, 2, 4]:
                base_json = change_addresses(base_json, x + sub_x, y, address)
            print(f"changed address {address}")
            address = address + 256

    print(json_to_blueprint(base_json))
    # entities = base_json["blueprint"]["entities"]
    # for entity in entities:
    #     if entity["name"] == "decider-combinator":
    #         print(entity["position"])




