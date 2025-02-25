import json

from bython_compiler.create_blueprint import blueprint_to_json, json_to_blueprint


def change_addresses(base_json, x, y, address, kill_address, apply_kill_address=False):
    entities = base_json["blueprint"]["entities"]
    for entity in entities:
        if entity["name"] == "decider-combinator":
            pos = entity["position"]
            if pos["y"] == y and pos["x"] == x:
                # change address
                entity["control_behavior"]["decider_conditions"]["conditions"][0]["constant"] = address
                if apply_kill_address:
                    entity["control_behavior"]["decider_conditions"]["conditions"][1]["constant"] = kill_address
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
    address = 193
    kill_address = 4

    for y in ys:
        for x in xs:
            apply_kill_address = x == 229  # memory cell
            base_json = change_addresses(base_json, x, y, address, kill_address, apply_kill_address)
        print(f"changed address {address}")
        address = address + 1

    print(json_to_blueprint(base_json))
    # entities = base_json["blueprint"]["entities"]
    # for entity in entities:
    #     if entity["name"] == "decider-combinator":
    #         print(entity["position"])




