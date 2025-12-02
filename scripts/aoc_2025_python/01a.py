data_path = "factorisco_v_assembly/data/aoc25_01_input.txt"
with open(data_path, 'r') as file:
    lines = file.readlines()
dial = 50
num_zeros = 0
for line in lines:
    if line[0] == "R":
        sign = 1
    else:
        sign =-1
    number = int(line[1:-1])
    number = number * sign
    dial += number
    while dial < 0:
        dial += 100
    while dial >= 100:
        dial -= 100
    if dial == 0:
        num_zeros += 1
print(num_zeros)