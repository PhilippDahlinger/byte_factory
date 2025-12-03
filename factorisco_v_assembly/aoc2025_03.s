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

# s0: current total result adder
# s1: first address of digit
# s2: second address of digit
# s3: last row indicator
# s4: "\n" 10 constant
# s5: start address of space to write row
# s6: temp
# s7: temp
# s8: current highest number

li s0, 0
li s3, 0
li s4, 10
mv s9, a0
li s10, 24 
lw s11, 0(s9)

la a0, loaded_data
li a7, 17
ecall # println

# sbrk for 100 words
li a0, 100
li a7, 2
ecall
mv s5, a0

0:
mv s6, s5 # temp counter
1:
call read_next_char
beq a0, s4, 2f
bnez a0, 5f
li s3, 1
j 2f
5:
# convert to number
subi a0, a0, 48
sw a0, 0(s6)
inc s6
j 1b
2:

# find highest number in array [:-1]
li s1, 0
mv s6, s5
addi s7, s5, 99
lw t1, 0(s6)
mv s1, s6
3:
beq s6, s7, 4f
lw t0, 0(s6)
ble t0, t1, 5f
mv s1, s6
mv t1, t0
5:
inc s6
j 3b
4:
# find second number: highest from [s1:]
addi s6, s1, 1
mv s2, s6
addi s7, s5, 100
lw t1, 0(s6)
6:
beq s6, s7, 7f
lw t0, 0(s6)
ble t0, t1, 5f
mv s2, s6
mv t1, t0
5:
inc s6
j 6b
7: 

# get value of row
lw t0, 0(s1)
lw t1, 0(s2)
muli t0, t0, 10
add t0, t0, t1
add s0, s0, t0 # update counter
# next row or finish
beqz s3, 0b
# end
end:
# print output
la a0, password_str
li a7, 16
ecall
# print output
mv a0, s0
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
	path_to_data: .asciz "/DATA/2503D"
	loaded_data: .asciz "Data loaded."
	loading_failed: .asciz "Data could not be loaded. Wrong path?"
	password_str: .asciz "Password: "