import sys
import base64
import json
import zlib


def blueprint_to_json(string):
    data = zlib.decompress(base64.b64decode(string[1:]))
    return json.loads(data)


def json_to_blueprint(json_data):
    compressed = zlib.compress(json.dumps(json_data).encode('utf-8'), level=9)
    return '0' + base64.b64encode(compressed).decode('utf-8')


def make_blueprint(blueprint, numbers):
    i = 0
    for entity in blueprint['blueprint']['entities']:
        for signal in entity['control_behavior']['filters']:
            if i < len(numbers):
                signal['count'] = numbers[i]
                i += 1
            else:
                signal['count'] = 0
    new_blueprint = json_to_blueprint(blueprint)
    print(new_blueprint)


def change_addresses(base_json, start_address=1):
    entities = base_json["blueprint"]["entities"]

    write_x = -245
    read_x = -241
    start_y = -306.5
    for y in range(32):
        current_y = start_y + 2 * y
        for entity in entities:
            pos = entity["position"]
            if (pos["x"] == write_x or pos["x"] == read_x) and int(pos["y"]) == int(current_y):
                # change address to y + start_address
                entity["control_behavior"]["decider_conditions"]["conditions"][1]["constant"] = y + start_address

    return base_json


if __name__ == "__main__":
    base_blueprint = "0eNrtXE1v5LgR/StGnxKEG6jIIiUZyCFBkMveggA5bAZGj92z04jdNtrt3QwW/u9hfcju3Ux2dkobZFgSDFhFimLpUd2q9zxv+MPm7e3T7uG4P5w2lz9s9tf3h8fN5Tc/bB733x62t9R32N7tNpebm931/mZ3/Or6/u7t/rA93R83z2GzP9zs/rW5hOc3YbM7nPan/U6u58aHq8PT3dvdsQ4IPzNP2DzcP9ZL7w+Ur073VcQcNh9qkLr+97nmudkfd9cyAsOm3uXpeH979Xb3fvvdvs5QL9N5r+q5G57rkXrPW/Wu3u2Pj6erV2ynDw90T9/tj6en2vNykzLiq78TRFqS05bWB6hx97A98l1fbv6wIdj3T6eHp9NPV+0TM/958/z85vn5OfzHSkXzSpUveqXCZ8/5x0/NOXXsrnSm7eHG/kgUwsOHujBPh9PVu+P93dX+UCfaXL7b3j7u6IHVB3C7/VAX72b3eH3cP8hCb7Y3N8fd4+PV98f9aXelC7z5yNNNL1m3dej7u91pf/2pB5w+96vwOvVPnvFnPoCvaUUedzTH1etz6Or6PuzqUxDov9tM6/1ZE3/0s4+f+9mHL+gtMffj/vVHpvl1P+H60vkvn+F48bf99T8v/nK7f6i/7h/+cfjT0+ni3f3xAi5OdOb0fndxsz1tL2S6i/rwdsdH7talns785tvjbnf47ce+ANn8iP+fr7e/tv96+/mHP73Ajrvtzc+9v4q5OuWF1fHevFLou45HD3V8mFPHs/c6Pppf8nmt423UcejMzxh9F/LYRCEHuyJPC6vkYJfk0XcpTx5KOczS5Ml7LQe7KE9rMW+kmNtVefRdzFMbxdwuy2FpxdyuyzvfxRxdFPNZwhzcF3O7Moe1mLdRzKNdmXe+izk2UcyjVZnHcVzav5VH81INvot59lDM4wxl/su/DM0W82hV5l/Ei2It5r+omGfzMx58F/PcRjEv5gq1OONbb14q58634qKYD3OKuXvrWxzNL/rV+9ZIMU+d+Rk7N7+VJop5sivzpbnfkl2ZO7e/9S5s7LOUuXv/W7Ir89UA10oxtytz5wa4vo1iblfmSzPAJbsyd26AG1wU81nK3L0BLtmV+WqAa6SYo12ZOzfADU0Uc7Qr86UZ4NCuzJ0b4EYPxRxnKXP3Bji0K/PVANdKMbcrc+cGuLGNYm5W5sPSDHBoVuaDcwMc/f9UB9V8jjQf3Dvg0CzNh9UB18qGMWZpPjh3wP3PX3G/TjnPZm0+LM0Cl83afPC++ZuL3d/yHHE+uPfAZbM4H1YPXCvl3CzOB+8bwLWxA1y2q/OlmeCyXZ07N8GBi03g8ix17t4Fl+3qfHXBNVLOi12dO3fBQRv7wBW7Ol+aDa7Y1blzGxy42AiuzFLn7n1wxa7OVx9cK+Xcrs6d++CgjZ3gil2dL80IV+zq3LkRDlxsBVdmqXP3TrhiV+erE66Rct7b1blzJxy0sRdcb1bn/dKscL1ZnfferXAuNoPr56jz3r0Vrjer8361wrVSzs3qvPduhWtjN7jerM77pVnherM6771b4VxsB9fPUee9eytcb1bn/WqFa6ScD2Z13nu3wrWxH9xgV+dLs8INdnXu3QrnYkO4YZY6d2+FG+zqfLXCtVLO7ercuxWujR3hBrs6X5oVbrCrc+9WOBdbwg2z1Ll7K9xgV+erFa6Rcj7a1bl3K1wbe8KNdnW+NCvcaFfn3q1wLjaFG2epc/dWuNGuzlcrXCvl3K7OvVvh2tgVbjSr87I0K9xoVufFuRUuutgVbpyjzot7K9xoVudltcI1Us6hM8vz4twLF9vYFg46sz4vSzPDQWcW6MW5Gy662BgOujkKvbi3w0Fnluhl9cM1U9PNGr04N8RFaKSm20V6XlxNt6t055a4GH3U9FkyPfuv6XadvpriWqnpYNfpzl1xsY0N4gDsOn1ptjgAu0537ouLLraIA5il090b4wDsOn11xjVT0+063bk1LqZGarpdp8Piarpdpzs3x0X0UdNn6XTwX9PtOn21x7VS06Ndpzv3x8U2toqDaNbpeWkGOYhmnZ69O+RcbBYHcY5Oz+4tchDNOj2vHrlmarpZp2fvHrncSE036/S8OI9cNOv07N0jV3zU9Dk6Pfv3yEWzTs+rR66Vmp7MOj1798i1sWkcJLtOX5xHLtl1unePnItt4yDN0un+PXLJrtNXj1wzNd2u07175PpGarpdpy/OI5fsOt27R27wUdNn6XT/Hrlk1+mrR66Vmo52ne7dI9fG9nGAdp2+OI8c2nW6d4+ciw3kAGfpdP8eObTr9NUj10xNt+t07x65sZGabtbpuDiPHJp1Ojr3yKXOR02fo9PRv0cOzTodV49cKzU9m3U6OvfIpUb2kctmnY6L88hls05H5x655GMfuTxHp6N/j1w263RcPXLN1HSzTkfnHrnUyD5y2a7Tnfu+ko+90bL9jwuLM0HmWTrdv0cu23W6c/tUamSLsWIX4avL8YtkZfVOv6/PhO7zGwgQSoA3oUax/iBHKSD3UU8KUaNeo+lsPRMy91E0aIT1hyKk2Xg+rFdkvqKODtDx6Zo0AHBv4bmRoxRG7utpZOSR/UvnQJ1yP0Ode+So/q4RcpRodgbT0VC5OcoSQEGCzIsS1/EChVIFEIAQz/oJGQg0YNwCjg4Uo8SJcvF4QhgFIaUMUSBCkflR4jpeEFHKEAUn9Gf9BDUKVCCsIGDpQDFKnCgXPyjCGwUvpQxR8EaQ+VHiOl4fLOGN+kDjWT/hjYI3Et4oeOlAMUqcKBePJ7xJ8FLKkARvLDI/SlzHCy5KGZLgjf1ZP+FN+lEjvFHw0oFilDhRLv7oEd6kHz7CmwRvApkfJa7j9aPKn2TBm+JZP+FN+tElvEnw0oFilDhRLh5PeFHwUsqAgjcVmR8lruMFF6UMKHhTf9ZPeFHwJsKbBC8dKEaJE+Wi8ZQyoOCllAEFL4LMjxLX8YIL+bsseDGe9RNeFLzI31X9svK3Vb+uhBcFL6UMWfBSypAFLxaZHyWu4wUXpQxZ8GJ/1k94s+BFwouClw4Uo8SJcvGLgvBmwUspQxa8GWR+lLiOF1yUMmTBm+NZP7+jBG8mvFnw0oFilDhRLh5PeIvgpZShCN5cZH6UuI4XXJQyFMGb+7N+wlsEbya8WfDSgWKUOFEufgUS3iJ4C7+TBW8BmR8lruMFF6UMRfCWeNZPeIvgLYS3CF46UIwSJ8rF4wlvr29kwtvrK7nI/ChxHS+4KGXoBW/pz/oJby94C+EtgpcOFKPEiXLx653w9oKXUoZe8PYg86PEdbzg6rn+CN4+nvUT3l7w9oS3F7x0oBglTpSLxxPeQfBSyjAI3r7I/ChxHa9liPAOWof6s37COwjenvD2gpcOFKPEiXJx5SK8g+CllGEQvAPI/ChxHS+4KGUYBO8Qz/q50gregfAOgpcOFKPEiXLxeMI7Cl5KGUbBOxSZHyWu47XCEt5R8A79WT/hHbX0Et5B8NKBYpQ4US4aTynDKHgpZRgF7wgyP0pcxwsuShlGwTvGs37COwrekfCOgpcOFKPEiXLxeGEYAnhkjtEJ4rFIBpS4XiHIRmYanUAe+7MTzDY6wTwy31DCwYxDKYdwjol0MOvolHZ0zDs6JR4daB7UFl2nJKNj9tEp/ejij84xA+mUgnTMQTolIR2zkE5pSMc8pFMi0vFKKNniuwigfItakg+1Rdcp8eh4PZR6Uev8HC+JMjBqIZ+TFjOTTqlJx+sykTFhYy90jNflhZCB5kNt0XWKXVjZRMuEl72c43WZqJlws4mcCTub6Jnws4mgMUODiaIxR4OJpAlLm2ia8LSJkIEwUl0X4Wov53hdJromfG0ibMLYJsrGnA2UtPFdBFDaxncRQIkbRNB8qC26biKrvC5xoqvxR+d4XZTCAXM4UBLHR26hthJnl+t4XZTK8V0EUDIHzOZA6RwwnwMlbnwXAZTSAXO613NC2HVdmNeBEjs+cgu1lTi7kG5eF6V3fBcBlOABMzxQigfM8SBNZJ3XRWkeMM97PcfrkiYqz+uiZI+P3EJtJc4u1/G6KOXjuwigpA+Y9YHSPmDeB0rw+C4CKPUD5n6v53hdlP4B8z9QAshHbqG2Emfn65gFgtJAvosASgSBmSAoFQQUbaPYmQ2C0kHA+KNzvC5KCQFF40wiR1TOJHN4XZQY8l0EUGrIdxFAySEwOwSlh8D8EJQI8l0EUIoIzBFfz/G6KE0E5omgRJGP3EJtJc4uokvUnq4L80X6IyZoS/Khtug6xc6skf6eHbV1fo7XRakjMHcEJY985BZqK3F2uU7WRe+auSKU6T4Lz6LPgfni6zlGq9STrgduJRaMjK/+xjdVu+9Pu7vN5ebt7dPu4bg/nDZh812V/Pz3glziiOOYETtMuTw//xsyNMTn"
    base_json = blueprint_to_json(base_blueprint)
    updated_json = change_addresses(base_json, start_address=33)
    print(json_to_blueprint(updated_json))
    # # save json
    # with open("temp.json", "w") as file:
    #     json.dump(base_json, file, indent=4)
    # entities = base_json["blueprint"]["entities"]
    # for entity in entities:
    #     if "player_description" in entity:
    #         if entity["player_description"] == "address_write_decider":
    #             print(entity["position"])