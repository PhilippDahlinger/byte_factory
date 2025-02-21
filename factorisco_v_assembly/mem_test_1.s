.text
.globl _start
_start:	
	li t0, 4
	li t1, 15
	li t1, 23
	li t2, 0
	li t3, 0
	sw t1, 0(t0)
	addi t1, t1, 1
	sw t1, 4(t0)
	addi t1, t1, 1
	lw t2, 4(t0)
	addi t2, t2, -20
	lw t3, 0(t0)
	subi t3, t3, 20
	halt
	
.data
	Here
	Random stuff
	is there
