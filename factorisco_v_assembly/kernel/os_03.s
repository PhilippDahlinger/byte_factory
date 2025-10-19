# simple OS, inspired by BrickOS
# asks for a number, then executes the program in this slot
# after ecall exit, returns to this loop and asks again for a number
.text
boot:
    # enable interrupts
	li t0, 1
	sw t0, 18(zero)
	# reset all regs
	li x1, 0
	li x2, 0
	li x3, 0
	li x4, 0
	li x5, 0
	li x6, 0
	li x7, 0
	li x8, 0
	li x9, 0
	li x10, 0
	li x11, 0
	li x12, 0
	li x13, 0
	li x14, 0
	li x15, 0
	li x16, 0
	li x17, 0
	li x18, 0
	li x19, 0
	li x20, 0
	li x21, 0
	li x22, 0
	li x23, 0
	li x24, 0
	li x25, 0
	li x26, 0
	li x27, 0
	li x28, 0
	li x29, 0
	li x30, 0
	li x31, 0

	li sp, 17400  # init sp
	li t0, 1100 # initial value of sbrk pointer
	sw t0, 256(zero) # address 256 = sbrk pointer

	# reset display
	li a7, 15
	ecall # cls
	li a0, 0
	li a1, 0
	li a7, 6
	ecall # set cursor to 0,0
	# set font to default: no wrap, and stride is 1
	li a7, 9
	li a0, 0 # font
	li a1, 1 # stride
	li a2, 0 # no wrap
	ecall
	# set fdr to 0
	li a0, 0
	li a7, 11
	ecall

	# reset keyboard
	# close and flush key stream
	li a7, 23
	ecall # close_key_stream

	# # debug: reset RAM initial values
	# li a0, 1024
	# li a1, 1536
	# 1:
	# sw zero, 0(a0)
	# inc a0
	# blt a0, a1, 1b

	# print welcome string
	la a0, welcome
	li a7, 17
	ecall


	# start main loop
	j main
	nop
	nop


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
	# TODO: Remove the next 2 lines, they are a bug
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
	welcome: .asciz "FactOS 0.3.1\n"
	selection: .asciz "ROM slot: "
	str_invalid_input: .asciz "Invalid input!\n"
	jump_table: .word 147968, 152064, 156160, 160256
	