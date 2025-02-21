.text
.globl _start
_start:
	li t1, 42	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	li t0, 4
	li t1, 52
	lw t1, 0(t0)
	lw t2, 4(t0)
	halt
	
.data
	Here
	Random stuff
	is there
