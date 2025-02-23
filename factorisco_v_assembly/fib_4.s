.text
.globl _start

_start:
	li sp, 1596
	call input
	call str_to_int
	call fib_dp
	halt
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	
input:
	# waits for an integer input, computes an int from that and returns that int
	li a0, 1000 # base address of the string array
	li a1, 0  # a1: length of the string
	li t0, 10 # ascii(10) = new line. check for that and stop reading input if thats the case
	li t1, 1
	sw t1, 3(zero)  # open stream and listens to keyboard
	_next_char:
	lw t2, 2(zero) # check if stream is not empty
	beqz t2, _next_char
	# stream has input if this is reached
	lw t3, 1(zero) # load stream content
	# check for new line
	beq t3, t0, _close
	# valid number (hopefully, don't check for letters for now)
	add t4, a0, a1 # address to save the string byte, base + offset
	sw t3 0(t4)
	addi a1, a1, 1 # inc string length by 1
	j _next_char # wait for next input
	_close:
	sw zero, 3(zero) # close stream
	sw t1, 4(zero) # flush stream to clean up
	ret
		
str_to_int:
	# a0: str base address, a1: str length
	_convert:
	li t2, 0 # result in t2
	li t0, 0 # array index
	_next_digit:
	beq t0, a1, _end_convert # int computed
	# shift already computed string 1 entry to the left = multiply by 10
	muli t2, t2, 10
	add t1, a0, t0  # current index of array
	lw t1, 0(t1) # load array index
	# ascii decode: -48 (assumes that string is numerical)
	subi t1, t1, 48
	add t2, t2, t1  # add new digit to working int
	# inc t0
	addi t0, t0, 1
	j _next_digit
	_end_convert:
	mv a0, t2 # return computed int
	ret
	
	
	


fib_dp:
	# create array of length (a0)
	li t0, 0
_loop:
	beq t0, a0, _end_loop
	sw zero, 300(t0)
	addi t0, t0, 1
	j _loop
_end_loop:
	# first 2 values are known: 1 and 1
	li t0, 1
	sw t0, 300(zero)
	sw t0, 301(zero)
	# _fib_dp works with a0 - 1
	subi a0, a0, 1
	push ra
	call _fib_dp  # a0 = result
	pop ra
	ret
	
	
_fib_dp:
	# check if already computed
	lw t0, 300(a0)
	# if not 0 -> already computed, return that directly
	bnez t0, _base_case
	# else: compute number and store it before returning
	push s0
	push s1
	# store index in s1
	mv s1, a0
	subi s0, a0, 1
	mv a0, s0
	push ra
	call _fib_dp
	subi s0, s0, 1
	mv t0, a0
	mv a0, s0
	mv s0, t0
	call _fib_dp
	add a0, a0, s0  # a0 = result
	# store result, index is s1
	sw a0, 300(s1)
	pop ra
	pop s1
	pop s0
	ret
_base_case:
	mv a0, t0
	ret
	
	