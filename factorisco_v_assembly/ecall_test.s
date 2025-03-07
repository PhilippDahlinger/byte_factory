.text
.globl _start
_start:
	li sp, 33000
	li a7, 1
	ecall
	li t0, 11
	halt
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	
.data
