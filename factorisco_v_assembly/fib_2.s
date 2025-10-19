.text
.globl _start

_start:
	li sp, 17407
	li a0, 12
	call fib_rec
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
	
	
fib_rec:
	push ra
	li t0, 2  # f(2) = f(1) = 1
	ble a0, t0, base_case
	push s0
	subi s0, a0, 1
	mv a0, s0
	call fib_rec
	subi s0, s0, 1
	mv t0, a0
	mv a0, s0
	mv s0, t0
	call fib_rec
	add a0, a0, s0
	pop s0
	pop ra
	ret
base_case:
	li a0, 1
	pop ra
	ret
	
	