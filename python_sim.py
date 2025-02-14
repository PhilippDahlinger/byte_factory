import re

from scripts.input_encodings.input_02 import main


def load_bas(input_file):
    with open(input_file, 'r') as infile:
        bas_code = infile.read()
        bas_code = bas_code.split("\n")
        bas_code = [x[6:] for x in bas_code]
        return bas_code


def cmp(r1, r2):
    print("in Cmp")
    global flag
    flag = r1 - r2


def jump(r1, *args):
    print("In Jump")
    print(r1)
    if len(args) > 0:
        r2 = args[0]
        print(r2)
    else:
        global pc
        pc = r1


def push(r1):
    stack.append(r1)


def pop():
    r1 = stack.pop()
    return r1


def cmov(r1, r2):
    # todo
    ...


if __name__ == "__main__":
    pc = 0
    r1 = 0
    r2 = 0
    r3 = 0
    r4 = 0
    r5 = 0
    r6 = 0
    r7 = 0
    r8 = 0
    r9 = 0
    r10 = 0
    r11 = 0
    r12 = 0
    r13 = 0
    flag = None
    stack = []
    user = [0] * 8

    bas_code = load_bas("output/test.bas")
    rom = main()
    mem = [0] * 2000

    while True:
        instruction = bas_code[pc]
        print(instruction)
        pc += 1
        # match = re.search(r'(?<![<>=])=(?![<>=])', instruction)
        exec(instruction)
