.text
.globl _start

_start:
	li sp, 17407
	li a0, 100
	call fib_dp
	nop
	nop
	nop
	nop
	halt
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	

fib_dp:
	# create array of length (a0)
	li t0, 1024
	add t1, t0, a0
_loop:
	beq t0, t1, _end_loop
	sw zero, 0(t0)
	addi t0, t0, 1
	j _loop
_end_loop:
	# first 2 values are known: 1 and 1
	li t0, 1
	sw t0, 1024(zero)
	sw t0, 1025(zero)
	# _fib_dp works with a0 - 1
	subi a0, a0, 1
	push ra
	call _fib_dp  # a0 = result
	pop ra
	ret
	
	
_fib_dp:
	# check if already computed
	lw t0, 1024(a0)
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
	sw a0, 1024(s1)
	pop ra
	pop s1
	pop s0
	ret
_base_case:
	mv a0, t0
	ret
	
	