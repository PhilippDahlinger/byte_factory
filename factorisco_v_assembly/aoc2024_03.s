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

# s0: buffer for complete result
# s1: buffer for first integer to multiply
# s2: buffer for second integer to multiply
# s9: compressed pointer
# s10: intra word counter 0-24, starts at 24 and counts backwards by 8. -> How much we have to shift current buffer to get desired char 
# s11: current word buffer
# init of vars
li s0, 0
li s1, 0
li s2, 0
mv s9, a0
li s10, 24 
lw s11, 0(s9)

mv s8, a0 # start pointer

la a0, loaded_data
li a7, 17
ecall # println

0:
call read_next_char
beqz a0, end
1:
# first check: == m?
li t0, 109
bne a0, t0, 0b

# second check: == u?
call read_next_char
beqz a0, end
li t0, 117
bne a0, t0, 1b  # jump back to check for m case with the same letter. (pattern mmul(..) would otherwise fail)

# third check: == l?
call read_next_char
beqz a0, end
li t0, 108
bne a0, t0, 1b

# fourth check: == (?
call read_next_char
beqz a0, end
li t0, 40
bne a0, t0, 1b

# try to parse first integer
2:
call read_next_char
beqz a0, end
# check if first digit is valid, if not jump back to start (since invalid syntax)
call parse_next_digit
blt a1, zero, 1b
mv s1, a1 # save first digit
# loop until no more valid integers are present
3:
call read_next_char
beqz a0, end
call parse_next_digit
blt a1, zero, 4f # exit loop, no more integers
# valid digit, updated number
muli s1, s1, 10
add s1, s1, a1
j 3b
4:
# check if a0 is == "," 
li t0, 44
bne a0, t0, 1b 
# first integer parsed, wicht "," at the end

# try to parse second integer
2:
call read_next_char
beqz a0, end
# check if first digit is valid, if not jump back to start (since invalid syntax)
call parse_next_digit
blt a1, zero, 1b
mv s2, a1 # save second digit
# loop until no more valid integers are present
3:
call read_next_char
beqz a0, end
call parse_next_digit
blt a1, zero, 4f # exit loop, no more integers
# valid digit, updated number
muli s2, s2, 10
add s2, s2, a1
j 3b
4:
# check if a0 is == ")" 
li t0, 41
bne a0, t0, 1b 
# successfully parsed complete pattern
mul t0, s1, s2
add s0, s0, t0 # update score

# next round
j 0b



end:
# debug
sub a0, s9, s8
li a7, 19
ecall # printint
li a7, 33
ecall

mv a0, s9
li a7, 19
ecall # printint
li a7, 33
ecall

mv a0, s10
li a7, 19
ecall # printint
li a7, 33
ecall

mv a0, s11
li a7, 19
ecall # printint
li a7, 33
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
	path_to_data: .asciz "/DATA/AOC24-03"
	loaded_data: .asciz "Data loaded."
	loading_failed: .asciz "Data could not be loaded. Wrong path?"