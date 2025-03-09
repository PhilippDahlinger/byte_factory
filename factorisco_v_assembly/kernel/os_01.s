# simple OS, inspired by BrickOS
# asks for a number, then executes the program in this slot
# after ecall exit, returns to this loop and asks again for a number
.text
main:
	# get cursor, set FDR to the row
	li a7, 8
	ecall 
	li a7, 11
	ecall # uses row in a0 as argument
	# print welcome string
	la a0, welcome
	li a7, 17
	ecall
	0:
	# TODO move FDR accordingly
	# ask for a program number
	la a0, selection
	li a7, 16
	ecall # print without a new line
	# input
	li a7, 25
	ecall # wait for next key
	# check if key is valid
	subi a0, a0, 48
	blt a0, zero, 1f
	li t0, 3
	bgt a0, t0, 1f
	j 2f
	1:
	la a0, invalid_input
	li a7, 17
	ecall
	j 0b # go back to input
	2:
	# call program
	li a7, 18
	addi a0, a0, 48
	ecall # print selection as debug
	halt
	nop
	nop
	nop
	nop
	nop
	nop
	
.data
	welcome: .asciz "Welcome to FactOS 0.1.0!\n"
	selection: .asciz "Choose ROM slot 0, 1, 2, or 3: "
	invalid_input: .asciz "Invalid input!\n"
	