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

# s0: current dial position
# s1: number of zero positions 
# s2: sign L = -1, R = +1
# s3: current number to build
# s4: 10
# s9: compressed pointer
# s10: intra word counter 0-24, starts at 24 and counts backwards by 8. -> How much we have to shift current buffer to get desired char 
# s11: current word buffer
# init of vars
li s0, 50 # init pos
li s1, 0
li s4, 10
li s5, 100
li s6, 0
li s7, 0

mv s9, a0
li s10, 24 
lw s11, 0(s9)

mv s8, a0 # start pointer

la a0, loaded_data
li a7, 17
ecall # println

# solve the AOC25-01
0:
call read_next_char
beqz a0, end
# first check: == L?
li t0, 76
bne a0, t0, 1f
# "L"
li s2, -1
j 2f
1:
# "R"
li s2, 1
2:
call read_next_char
# has to be a number
subi s3, a0, 48
9:
call read_next_char
# either new line or another digit
beq a0, s4, 3f # skip next digit
# apparantly another digit
muli s3, s3, 10
subi a0, a0, 48
add s3, s3, a0
j 9b
3:
mul s3, s2, s3 # correct sign
slti s7, s0, 1 
# update dial
add s0, s0, s3
# check if dial > 100
5:
ble s0, s5, 8f
subi s0, s0, 100
inc s1
j 5b
8:
# check if dial < 0
bge s0, zero, 6f
# if previous result was 0: subtract 1 from s1 (0 -> -14 is not going over 0)
sub s1, s1, s7
6:
bge s0, zero, 7f
addi s0, s0, 100
inc s1
j 6b
7:

# check if zero
bnez s0, 4f
inc s1 # inc zero counter
4:
# check if 100. if thats the case: set to 0 and inc s1
bne s0, s5, 5f
li s0, 0 # set to 0
inc s1
5:
# go back
j 0b

end:
la a0, password_str
li a7, 16
ecall
# print output
mv a0, s1
li a7, 19
ecall # printint
li a7, 1
ecall # exit

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
	path_to_data: .asciz "/DATA/2501"
	# path_to_data: .asciz "/A"
	loaded_data: .asciz "Data loaded."
	loading_failed: .asciz "Data could not be loaded. Wrong path?"
	password_str: .asciz "Password: "
	dot: .asciz "."