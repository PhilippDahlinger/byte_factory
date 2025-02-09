

def get_data():
    input_file = "aoc_2024_inputs/02.txt"
    with open(input_file, 'r') as file:
        lines = file.readlines()
    lines = [line.strip().split(" ") for line in lines]
    lines = [[int(x) for x in line] for line in lines]
    return lines

def check_row(line):
    if line[0] == line[1]:
        return False
    if line[1] - line[0] > 3:
        return False
    if line[1] - line[0] < -3:
        return False
    if line[0] < line[1]:
        monotonic = True
    else:
        monotonic = False

    lives = 1
    a = line[0]
    b = line[1]
    for i in range(2, len(line) + 1):
        diff = b - a if monotonic else a - b
        if diff < 1 or diff > 3:
            lives -= 1
            if lives < 0:
                return False
            try:
                b = line[i]
            except IndexError:
                b = -100
        else:
            a = b
            try:
                b = line[i]
            except IndexError:
                b = -100

    return True



if __name__ == "__main__":
    lines = get_data()
    correct = 0
    for line in lines:
        if  check_row(line):
            print(line, "+")
            correct += 1
        else:
            if check_row(list(reversed(line))):
                print(line, "+")
                correct += 1
            else:
                print(line, "-")
    print(correct)