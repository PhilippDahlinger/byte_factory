.text

# load data
la a0, path_to_data
li a7, 40
ecall # fs_load
# a0: pointer to file in RAM
# a1: length of file in RAM (not needed for our stuff)

# check if file could be loaded
bge a0, zero, 1f
# error case
la a0, loading_failed
li a7, 17
ecall # println
li a7, 1
ecall # exit
1:

# s1: current total result adder
# s2: first number build up
# s3: second number build up
# s4: "-" 45 constant
# s5: "," 44 constant
# s6: mark if end of file

li s1, 0
li s4, 45
li s5, 44
li s6, 0
mv s9, a0
li s10, 24 
lw s11, 0(s9)
mv s8, a0 # start pointer

la a0, loaded_data
li a7, 17
ecall # println


# parsing
0:
call read_next_char


# has to be a number
subi s2, a0, 48
1:
call read_next_char
# if "-": go to next number
beq a0, s4, 2f
# new digit
muli s2, s2, 10
subi a0, a0, 48
add s2, s2, a0
j 1b
2:
# second number parsing
call read_next_char
# has to be a number
subi s3, a0, 48
1:
call read_next_char
# if "," or end of file: go to processing numbers
beq a0, s5, 3f
beq a0, zero, 2f
# new digit
muli s3, s3, 10
subi a0, a0, 48
add s3, s3, a0
j 1b
2:
# set end of file marker
li s6, 1
3:
# process stuff
# s2/s3: numbers
mv a0, s2
mv a1, s3
# check the 4 multipliers
# 11
li a2, 11
li a3, 1
li a4, 9
call process_range_with_multiplier
add s1, s1, a7

#101
li a2, 101
li a3, 10
li a4, 99
call process_range_with_multiplier
add s1, s1, a7

# 1001
li a2, 1001
li a3, 100
li a4, 999
call process_range_with_multiplier
add s1, s1, a7

# 10001
li a2, 10001
li a3, 1000
li a4, 9999
call process_range_with_multiplier
add s1, s1, a7


#100001
li a2, 100001
li a3, 10000
li a4, 99999
call process_range_with_multiplier
add s1, s1, a7


# if not end of file: jump back
beqz s6, 0b
# print output
la a0, password_str
li a7, 16
ecall
# print output
mv a0, s1
li a7, 19
ecall # printint
li a7, 1
ecall # exit


process_range_with_multiplier:
# a0: lower number
# a1: higher number
# a2: multipler (11, 101, 1001, 10001)
# a3: multiplier lower range
# a4: multiplier higher range

# computes:
# a5: input lower range
# a6: input higher range
# returns: a7: sum of the desired invalid ids between a0 and a1 (therefor not overwriting other regs)
div a5, a0, a2
# if mod a0, a2 != 0: add 1, (multiplies of multiplier are ok, but otherwise the flooring of div will have the lower boundary too low)
mod t0, a0, a2
beqz t0, 0f
inc a5
0:
div a6, a1, a2
# check if bounds are not overlapping
# a6 < a3 -> ret 0
bge a6, a3, 1f
li a7, 0
ret
1:
# a5 > a4 -> ret 0
ble a5, a4, 2f
li a7, 0
ret
2:

# get max(a5, a3), min(a6, a4) in t0, t1
blt a5, a3, 3f
mv t0, a5
j 4f
3:
mv t0, a3
4:

bgt a6, a4, 3f
mv t1, a6
j 4f
3:
mv t1, a4
4:
li a7, 0
6:
# go from t0 -> t1, multiply with multiplier and add to result
bgt t0, t1, 5f
mul t2, t0, a2 # t0 * multiplier
add a7, a7, t2 # running adder
inc t0
j 6b
5:
# return output
ret

# args:
# a0: next char to check. already tested for 0x0
# returns:
# a0: orignal input (for reprocessing if needed)
# a1: -1: error parsing digit, 0-9 digit which was parsed 
parse_next_digit:
	subi a1, a0, 48 # -> valid range is now 0-9
	blt a1, zero, 1f
	li t0, 9
	bgt a1, t0, 1f
	# a0, a1 set properly
	ret
	1:
	# invalid char
	li a1, -1 # error code
	ret
	
read_next_char:
	# no input, but requires state s9-s11 to be correctly initialized and not-altered
	# returns: a0: next char
	# shift current word by s10 amount
	sra a0, s11, s10
	andi a0, a0, 255
	subi s10, s10, 8
	blt s10, zero, 1f
	ret
	1:
	# load next word
	inc s9
	lw s11, 0(s9)
	li s10, 24
	ret
	

.data
	path_to_data: .asciz "/DATA/2502"
	loaded_data: .asciz "Data loaded."
	loading_failed: .asciz "Data could not be loaded. Wrong path?"
	password_str: .asciz "Password: "