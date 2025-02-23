import json

from bython_compiler.create_blueprint import blueprint_to_json

base_blueprint = "0eNqtnN1y46gWhV9lytfRlIX+u+pczP15g1NTU1jGNhP9NZLizkzl3Q/IsbW2HSW9UV912onXRsAHG1jo382uGlVndDNsvv270WXb9Jtv//t30+tjIyv3WSNrtfm2cb8ZZDMEZVvvdCOH1mzenja62asfm2/h2xN+Z3jt3HdetBlG+8nTVeTyF8Ef8E3B+uZ/4ZuR9zfjtz+fNqoZ9KDV5XGn/7z+1Yz1Thn7OE+fPfbTpmt7+922cXHdM2yz35Onzav7Kfw9sYHs1wbTVn/t1Em+aPsd+4e9Kt13evqzDX6tw6fNQVeDMvefvhfl3LZ71QTlSfWDLcN3+5S2zPYXTWvq6YltGTtppjJ+2/xn+mB0DTu1zrW+b3ratF5qAtSiuZoHpSofuQjkYpBrjTyqwNb9M08vBr3kpjcY2fRda4ZgpypmCRNQTG+KB9kPwRrZFGSzm6z60RnV96uUM1DOb8qj/cAcjf2TvYdmDpoFrYR1wgUIh9uHelgnHm5RfWap76yCRY2phiCFgtaCpyTSFEYPj++pilCFM1W70TTKBLrpleGLIlnhjJanGlIVzlhVbXMMTtJ+vvctJ4IVZrSVPCWRqDCH+qyefSURqHAmqrdfqwJV2QnC6DLo2koxhREoMQNVq70e6zXKAmESM0w7fVwlS6anmap+3Nmpd5pmeXqIlJiR6nTHLRliJGKiFAxtcBmWmJpIkZgp6sa6YyohQWImyEhdMZWQGJHhpKmbwE7F3JIhLiInJQveMzaeIMIiCipYnqZS+sgiKtEWxiD7jXbQL8z+EiEgESSR0hzb4CyP3K4cIRoRTDjVqPdegiR5m9mQZtBVpcyrlyhiEsX42EwhZCOC5I2dBEbIRpTCvK9tOmFTc+4jIiFRBj3lqPvBDnum3bXcxBcpiXK65DDjtEDw0kVYohkWWboeHXSmfXGV4JWrIzDxDEwn+36tdozwxOHDSsBHEvGJBUzbh4NnIZGfeObHqO+jFfMUJUugmR/X9m4FwFRDiOLkLrGoJHeaiRGlOIUhQw+nWrnOT9bGHGmkKp6p2qvy0ot8dZGseCarn7KUdoUwohUXX+wScIQRrATAas+2HvqzHsoTc9GKOCUzThbRo5F1LXeVsqsLJZ+5mWuCVCUzVXttFyvyNehko5gTcYJYJbip0DYq2Nm8kjn+J4hUEmNDlUYNzHk9IXsKM1In+Y80+8BTFLlKIH1TB90ob1VEKskeVNcVGblKZq4qu1w72PyBqYYwJQBTpQ+HwC6Aq9ZNKj1TFUlKt1ABndTGdk5uV0oRpBRWPbeNU54c0pMKHPNw3rckNQ2XzBQxSmeMxs4iv1eeoohSGj8+f7BrW26dIlDpDNSu1RW7fGR7LsUNSWmXu83R9numIjKUzgz1bSWNz/CWIjdpDhlZOdZjxZ8uUkQnndFpxrJStoxGyZIviuRkMzknJYeAv3jOkJsspHLqh121NUduW2cITybu2noYzY7d2Bkyk0X3W2W1bnRzDPaGPbxlyE02c3PbKVkhjfhkMz7t4dCfWmNBZ28mZEhRlpJtib/ZY2ZG9razu/n8YKtWltx2Qoay/O7cwU8SKcqKxxbyU0WM8hkju0RS9a5yTV7L8mQ7ahAyt+CRqDz8TFkwlZGrXHymHDGVEa98xssO9MElJzGvTEXkKofU7qRqXcpqmuW4hxsIVD4DVarGdoTDeGT2gRxpymFzW+6YQghSPoO0swM8dw8jJ8dCQFCnbGJYt/uRu3ObI0B58aEiuysiPsX2Y01mJywQnGIGRx0OutSqKV+9Hr9AagqxLMutgwKhKaJPhLkVgewUMS4K9y7xfLE6flWBABXJZ8LsykCWivRTaW51IF0FLJba8lkNQa+rlimIiBX53QawWya5obSTzDODghy+AmdyUJUV4TYWPXK1jL17J4wqL2nedZSRvZ0F3VBtK7tUfW9Lzz1/JQew23Axlty/yKa0iK8LR05ot2IxXNnamaLS30d1kCX/jMlKk0DRYiCb7r68Tg9VGptHeTwSOcvdxouRKn08DasikQPebbIYyS6E9N5mRy7xMm0ddMqZXdRYB0fZc4OSc+Bt+tNBb4/LDUiOh7fZTwe8tSQ3IDk83ubE0MPVIqfG24L0Z64WGQbAejFl6VxnBDVahNRlZNckXD0CMngtyrbr7LrMQ5EQC1aL0cjGnYx7SBI0wWdh5Dk46P7E1SMAosXCXLaEBnYJCV1gs3ivRi9NAlCY3S3FvCQJImCwmBnkKhJQwF9hizcd2O0k2/xDeAFnRT9WdqXI9f0QYNBNIZ3f55UrR61JAo1EXvuoIbFRhOCjOEt3zmXrz7BbhRgqQnBUlGbcq2nu8tMl4KCrAmcmT22CEPgs5vnWT5dgBK6LOWPw0yUsgfuiGt1Bijul8tMlRIEJ49L9LVKytKz6aRO0ouWMdEXfI+aMMFrORFf2ReLZCKPlFPQX9M2Iugejn8gN/eIQbqP4J7JdvziE42g5A13Zl4k9JIw+STrX921iHQmj5XxT1d3g/Df+PZyQ7xwln0Za28/JeOB8Jp9G+xW9nYwS8faLiCv7PPGjhHH4RbSVPZ9YVcJYfPVs6/o/sbGEcfRFtF9AQUwdyTFNbY/u0Op8UnxZMmDEdxmzS/SeuYpkaIgfMubSGSe4mmQIAKOLX1USzMHecjm3aBvnyNGmHDXXLE/sLSH4W26bM566BFy0t9z2eYKxYcsSi0sIHpfLoa+XJMEQzC23M6EV2gQ6cLkcqldXA5PVLzgY9yFTmcAFdpeqPQd71fRui/TiLRjZi9yE2v6T+11Sj8UZsb6EyfL0+x7CqrArmyCXLM+619W/95YjMcWE4Iq5Koso4UoSDsEaM0vmXEmCIPhirpLTPlepuEfRIbHHhOCP2auuUoMdM1ZHIEymy1Pj1f0wBTLKu0WJjSZMl2fH5/ZFGvXDjgl2ZDjVyk7H70G5EQnAYLLBR+JqEm7BZCPHoa2nexVBP50mKQ9XVJjS+zvpoyV6jTihFyw4tbYa0ryuEifAgh3ndoK8RpygC9ac63HVylonGINJZxxczayqF2LYCTO8LCet4hplQjD4djrbU1puxyaOnRAsO/24u7oUjiP3QIfYdULw6/SndvCQI/SBR8c5hOUQeKoS6MCm8z5RVnJsbC9m326jN+bgylxl/x1OxrmQuZqEMjDsHLSxI1od1PIo/2HbtUJi2gnBtdNpZcpLHjU2+95bnxCWP06U6+SJhycEE897h7Adgz9DEvtOmIvHOlmlTngDD49dfzatpyahDVw8t+3qYI06gQ/8PNc2XKNNEARvz1zyXxGFEAnGn/milpcsvcea340fXDWCIvh/5qrw0yUIggfI/m3tjm7sEMq9E0uwAwsQjnCBrOuWK0zQAxPQ0ahG7tl3dwlrYP0pq3G6XuQpS3BD40+re/cWCNn1I/+iMcEMXD+9XXfu27O3LkEMLD97dVDNdDHIT5dAVcxrwsvbPzYPcbj6hK4iX9a3aY/xcGiHBb00XnzyBDZC+8p/BHp5fPtBkf0qXxAjkNiGj0X1FSbXx7fi7szDphrcahbE3CO20d3xhpckuUq+nQmcnGt2heclSu6Sb5O7a2NekuRS+Tb9SDKonwVXltww3354pyJQ30fduVU0V5xcN99iqmmX/+4S7eU6hH8Acv0cXDfvZ/X+wgQ3sOBchW1Ne4uH9HUN4DBQ1RDounZ7mP5lJw4dEaLjoO2fVaUGW/Pe4oRAMOt0ytgJy67Rr5dj/UMQIsG88xhiVSsQRsHT00zD04ueeqi3OsEV/D2qUebokkStqr2/PMEWrD5UflX9EHjB+nNrhkr2duSZ5uRe+cchDIMhyM5s5Umao1ofgtAs7gx1wVly83VB37gCJqEj22Ml7l6zIsCstud6oQR9xwqYg5zH2d1sYpeO0AjOILdqHUZjuKsIQV+0Ap6gS3/y0yS4gReILCP8pAlq4qMVn58u4UvMSen0DpE7Zw1XmzAliiXt6XoeV5vABJagO+2bi4H7ah+CFtiB7vRXeJsFsQIJsALdxfC0MouIvukoWtL3dC4LYvsRYPu5L//VjcDVJ4iC3ee+/6D/gBuDIAtWn/sl0+X9GDvNx4A4fES0vK58fwWXVwyCcbS8tnQv4/IKQFiOlpeWO3VSdTuc/KIQqsHC83Fr9J3Hy+8Ece4IcO4stIdnFAI3OHY+ahHPEIRvsOkstolnHPqes/iLVjlbQb/JiNh1RJx81TIrIhHs4/TT1lkRhqAfZ1+30IpYZAiIPxsC3E5h38lzw+8KZBiIl4eB957mG4aMA8nyODC9DIT7XjzCf7LMv8v7ZcnnhbiERPIF+i4jdvvg3CAE/mQZ/tN4VF4BCPXJMvW+KVZCX3WYfPAWtsA4KriLBeIfEvDunMe1nJ9+6l4Q7d7u2Nnf/FFVv9mPfrNU1f3m7c+3N/db97+7t8C82BXr9FLoJBVFXBRJkoR5nMZvb/8H0WG+rQ=="
base_json = blueprint_to_json(base_blueprint)
# save json
with open("temp.json", "w") as file:
    json.dump(base_json, file, indent=4)
raw_signal_list = base_json["blueprint"]["entities"][0]["control_behavior"]["sections"]["sections"][0]["filters"]
signal_dict = {t + 1:x["name"] for t, x in enumerate(raw_signal_list)}
with open("output/signal_dict.json", "w") as f:
    json.dump(signal_dict, f, indent=4)
