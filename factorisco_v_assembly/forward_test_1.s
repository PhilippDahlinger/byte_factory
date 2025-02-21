.text
.globl _start
_start:
	li ra, 0
	li t0, 0
	#li t1, 25
	#sw t1, 4(t0)
	li t1, 0
	lw t1, 4(t0)
	bnez t1, wrong
stop:
	halt
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
wrong:
	li ra -1
	j stop