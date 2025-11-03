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


def generate_item_list():
    base_blueprint = "0eNqdmN1u6ygQgN/F12GlnjbVtq9ydBSN8dhmg4EdIGm2yrvv4LRpq2aw1asq5WMGhvn1a9PajIGMS83za2O0d7F5/v3aRDM4sOV/DiZsnpsOtemQlPZTaxwkT8150xjX4UvzfHf+s2nQJZMMXvbPP047l6cWiYFNRc6mCT7yVu+KPhb3+LBpTrzp8emvLSvpDKG+LPMCHzGRt7sWRzgY3s573oTueK2bBcXy38+/fvMBfU4hJ+F+R+87dEqPGFNzPm9uIIZ8HYgJ0S4QnmBAlcDtBSQRuBg8JdWileT0EJNaReJLIIxxHZz5OWkgz38Xta9k3/WvxGOwJiV2mYrmBeZd4wLWZnLsh8ZFJJlaWLbeDWoEvlu3JGk++gLTZrtfYuIE1iq0HBJktAreokBO2Jk8rUJbM6ziYm5jgjkWbwPBBKwsqeTVxQkkKE9BWCIwVo4Z4xQHV22vevtvhdDjLKfGWc+ZyydzkK6pgQavjjCINuptNl2VAErGWqRTlWJNkj3k9BJDyZScQZ14wcHExG5AvvVSmJY6kSjPWbkKgi6mUoH84ZL2K8kxQIyr4fdMWmPa3PcLYgj/zby6RPENS+6shqQF0XWBTBonLFb9XD9vsrcK7W2tc8D6FeT8WuDSMhn8kVXHo0l6lBDyA8E0QWuRcyzCXkxVneEcDCcVwKGV39Ghajnv7OXTa8IkxdsI/wF1aoEi7I3D1dg6oZYTf8+BKh3cmr5XXI6sL34dRZ0BDLGRRAt89Giiy3yOR7a5c+Kj5MDP1+ECdVWpWu/Fc3lj5TqVELj4uIENKiHeAlW9A7TOU7YVj3VZW2QphKBlakRIqlKb5nV84fzvhoUbpUytfKW3rmIyznBn0JHsHddyu4L1fR9HT/xocnksS//IPnSJs56PBxqr/WuduR67jnEqx6m15WIT6JENpu7Wo7/Wo/eSybicX6KZTlJ8jjgZDXYOBbHS8SRDps+DnARayRfYJcUyy5mT88zkuyw3W58Q0SRfIMkY2PdGG3T6VNf4jRPVfifv5XrRlcR04Hmwrv0GKeq/xd6L1VvvkccGY321ZyvpvLhWAKk7jZDQ8lTx7QbpFC6pXJcccx12W4gcKcUV+byahxIWv3IrdAdwmp/2R7u1Z7e2hnubHvStdl3Yx3nwcJpVauJcsl6hNcOYfrKRawA3w30uiYf8pAKW6R55bhkg/lDG9TA/3H+1guAG5VuB2KxAtdOpfVrgBC9KDYGrigxknu7LrCcTBEfVmzjWDsB5MC0coYZcykeVuBpaCmsL8+zRiqNNzJYrj5RxoQz8J/nDQL0TO0IZBFg3iQfUlLl3Kn5exb54cR39iJwq9hGZdWm5tNKl169iFyuyoYGHjQ/0D9PlDU5Iuw6jJhMu3904HXXlo8ruyJMM7t5mlKZ89uPf05ceddMckOK8bfv46+nh6Wm73d79/fD4cD7/D7DtMdU="
    base_json = blueprint_to_json(base_blueprint)
    # save json
    with open("temp.json", "w") as file:
        json.dump(base_json, file, indent=4)
    output_list = base_json["blueprint"]["entities"][0]["control_behavior"]["decider_conditions"]["outputs"]
    output_list = [output["signal"]["name"] for output in output_list]
    print(output_list)


def generate_rom_v2_data_combinator():
    base_blueprint = "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"
    base_json = blueprint_to_json(base_blueprint)
    for entity in base_json["blueprint"]["entities"]:
        for idx in range(256):
            entity["control_behavior"]["sections"]["sections"][0]["filters"][idx]["count"] = 0
        del entity["control_behavior"]["sections"]["sections"][0]["group"]
    # save json
    with open("temp.json", "w") as file:
        json.dump(base_json, file, indent=4)
    print(json_to_blueprint(base_json))


if __name__ == "__main__":
    # generate_rom_v2_data_combinator()
    # exit()
    base_blueprint = "0eNrtXG1u2zgQvQt/K4WGpL58iv4PAkOx2FRYWzYkOa0R6AA9yF5sT7IcjSh5N8UuS1XYLjDIjzxTo+Eb8ol5EDJ+E8/Hq7m0ddOL3ZuoD+emE7vHN9HVL015xLGmPBmxE5U51JVpHw7n03PdlP25FUMk6qYyX8UOhqdImKav+9rQ/eOH2765np5NawMilwdn6Mumv08Uicu5s/eeG5zQ5nvI8uxDEombhSDzD4mdqqpbc6AYHWGavj0f98/mc/la2xz2xo6ud3/FlszCchiG6B05Gf1Dkd/jlv4osynv3l6r6pnj/SfL8lPddv1+Wfj+dkFOr3XbX+3ITJIiHhSuv1tNscuhkDEOnC5lOzLfiT++/W5vu8+7b0z/5dz+Ns7fmkrs+vZqIvHSGmPpfyqPnRlcFrOfKJRNJXDdVjKUkKU/jY4V3PnaX6793/X6L6TMq2lv/ee6eUF27+Yfp5wJIJsBVWNVcCxvdgcr0x3a+kK7Lcqqak3X7VtTVvtpk8V3FKZ+VGH6V1DYx19eYR9ZYZPC9JoDNt34gE3WkMs2JpcGn/4pn/58+ns8m1mwwjJWGCvMQ2F5sL9I2V+wv/BQWBGssIwVxgrzUBjEa1yi3tglwqo3GMnW7MJfYWi2GGwxfB5PFSyxhCXGEvORmA42GZpNBpsMH4klwRJLWGIsMR+JpWucotzaKWZr2Kmt2eXBJkOyyWCT4fN4FsESUywxlpiHxGQcbDIkmww2GT4Sg2CJKZYYS8xHYnKNU4y3/p8ttYYdbM1OB5uMmE0GmwyfxzMJlhiwxFhiPhJLg01GzCaDTYaPxLJgiQFLjCXmI7F8hVOEzXsPijXsio3ZqTjUZAC3RrDJ8GqNgGCJFSwxlpiPxGSoyQBuv2GT4SWx4A6v//QUY4n9jyS2psULtm7xUmt6vGDrHi8V3OQF3OTFJsPr8Qzu8gLu8mKJeUksuM0LuM2LTYaXxIL7vID7vFhiXt9UsKbPC7bu89Jr+rxg6z4vHdznBdznxSbD6/EM7vMC7vNiiXlJLLjPC7jPi02Gl8SC+7yA+7xYYl4SW9PnBVt3Uunw11Hc5sJ/xr0egPDXUdyDwGfse4lZal+sJJDYI0QSf56iRxlBlEUwIhmpaUzZMWWRsleL8aqyY8U4pm1cOsYlFmUjSucsiEBNUEb5dNklRGQvI7R32ox4OZ9nQQTJBN2EiOwgQojtTUDMAYsAYgxymZZw4bD9pF3MPDdhSo8pMP8YoxcCI5bg8MIBsR0fMdYIVCRgQUAVQX7HAbFMHLaMYhezcEAsp/wFxgDtRLxwIJw5PHMgTMsrx22leiXWJakuqRcOI1bgsI1JXczMYcRqyo/bLGmfZXrHAbFSDi8cECtaZ4n1KqpXYl2K6lLxwoFw5rCNkS5m5kB40iTuu6J9V3LhQLhweOZAmNZZYb2K6lVYl6K6VHrHAbFWDtuY3MUsHBDrKT/uu6J9V/kdB8Q6cXjhgFjTOmusV1O9GuvSVJeWCwfCmcM2RruYmQNh4oYpMP8YoxcOhHOHFw4jzgljvZrWBH/huHyyJ0fdm5M9WZavs46EPbG68bxJUlnookiyQitZpMPwJ/DNQh8="
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
    xs = [-786]
    address = 62464

    for x in xs:
        for y in ys:
            for sub_x in [0, 2]:
                base_json = change_addresses(base_json, x + sub_x, y, address)
            print(f"changed address {address}")
            address = address + 256

    print(json_to_blueprint(base_json))
    # entities = base_json["blueprint"]["entities"]
    # for entity in entities:
    #     if entity["name"] == "decider-combinator":
    #         print(entity["position"])




