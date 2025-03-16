# simple OS, inspired by BrickOS
# asks for a number, then executes the program in this slot
# after ecall exit, returns to this loop and asks again for a number
.text
main:
	0:
	# ask for a program number
	la a0, selection
	li a7, 16
	ecall # print without a new line
	li a0, 512 # string address of input
	li a1, 10 # max length 10
	li a7, 26
	ecall # input
	# create int out of string
	li a7, 31
	ecall # str_to_int
	# check if a1 is -1
	li t0, -1
	beq a1, t0, invalid_input
	# check that range is in 0-3
	li t0, 3
	bgt a0, t0, invalid_input
	blt a0, zero, invalid_input
	# all tests passed
	mv s0, a0
	# call program
	li a7, 18
	ecall # print selection as confirmation
	li a0, 10
	li a7, 18
	ecall # print new line
	li a7, 23
	ecall # close key stream
	la t0, jump_table
	add t0, t0, s0
	lw t0, 0(t0) # user program location in t0
	
	# disable kernel mode
	sw zero, 15(zero)
	
	# call user program
	jr t0
	
invalid_input:
	li a0, 10
	li a7, 18
	ecall # print new line
	la a0, str_invalid_input
	li a7, 17
	ecall
	j 0b # go back to input

	
.data
	selection: .asciz "ROM slot: "
	str_invalid_input: .asciz "Invalid input!\n"
	jump_table: .word 147968, 152064, 156160, 160256
	