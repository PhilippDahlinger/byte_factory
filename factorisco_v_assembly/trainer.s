.text
_start:
	call init
	
game_loop:
	# random values of operand 1 and 2
	mv a0, s0
	li a7, 27
	ecall # rand int
	mv s2, a0
	mv a0, s1
	li a7, 27
	ecall # rand int
	mv s3, a0
	
	0:
	# print exercise
	mv a0, s2
	li a7, 19
	ecall # print first operand
	la a0, str_mul
	li a7, 16
	ecall # print
	mv a0, s3
	li a7, 19
	ecall # print second operand
	la a0, str_eq
	li a7, 16
	ecall # print
	
	# input
	mv a0, s4
	li a1, 20
	li a7, 26
	ecall
	# check if string starts with "Q" -> quit
	lw t0, 0(s4)
	li t1, 81 
	beq t0, t1, quit
	# else try to parse the string
	mv a0, s4
	li a7, 31
	ecall # str_to_int
	beq a1, zero, 1f
	# invalid input: msg and go back to print the exercise
	la a0, str_invalid_input
	li a7, 17
	ecall # print invalid msg
	j 0b
	1:
	# a0 is user input
	mv s5, a0 # save
	# compute correct result
	mul s6, s2, s3
	beq s6, s5, 1f
	# wrong case
	la a0, str_wrong
	li a7, 16
	ecall # print wrong msg without ln
	# print correct result
	mv a0, s6
	li a7, 19
	ecall # print_int
	# print "."
	la a0, str_dot
	li a7, 17
	ecall # println
	j game_loop
	1:
	# right case
	la a0, str_correct
	li a7, 17
	ecall # print correct msg
	j game_loop
	
	
	
quit:
	# exit
	li a7, 1
	ecall # exit
	
	
init:
	push ra
	# set fdr to cursor row
	li a7, 8
	ecall
	li a7, 11
	ecall # set fdr to current cursor row
	la a0, str_init
	li a7, 17
	ecall # printlnf
	li s0, 100 # max value of operand 1
	li s1, 100 # max value of operand 2
	# s2, s3: actual numbers of the operands
	# s4: user input address
	# s5: user input as int
	# s6: correct result
	# fixed address of the user input str
	li a0, 20
	li a7, 2
	ecall # sbrk of 20 words
	mv s4, a0
	pop ra
	ret
	

.data
	str_init: .asciz "Welcome to \nMulTrainer!\nEnter 'Q' for quit.\n"
	str_mul: .asciz " * "
	str_eq: .asciz " = "
	str_invalid_input: .asciz "Invalid!"
	str_correct: .asciz "Correct!"
	str_wrong: .asciz "Wrong! It's "
	str_dot: .asciz "."