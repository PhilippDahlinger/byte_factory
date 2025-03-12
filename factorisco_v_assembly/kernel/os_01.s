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
	li a7, 22
	ecall # open key stream
	# input
	3:
	li a7, 25
	ecall # wait for next key
	# handle scrolling of terminal
	li t0, 9 # up is pressed
	beq a0, t0, 4f
	li t0, 8 # down is pressed
	beq a0, t0, 5f
	
	# check if key is valid
	subi s0, a0, 48
	blt s0, zero, 1f
	li t0, 3
	bgt s0, t0, 1f
	j 2f
	1:
	li a0, 10
	li a7, 18
	ecall # print new line
	la a0, invalid_input
	li a7, 17
	ecall
	j 0b # go back to input
	4:
	# dec FDR
	li a0, -1
	li a7, 12
	ecall
	j 3b
	5:
	# inc FDR
	li a0, 1
	li a7, 12
	ecall
	j 3b
	2:
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

	
.data
	selection: .asciz "Choose ROM slot 0, 1, 2, or 3: "
	invalid_input: .asciz "Invalid input!\n"
	jump_table: .word 147968, 152064, 156160, 160256
	