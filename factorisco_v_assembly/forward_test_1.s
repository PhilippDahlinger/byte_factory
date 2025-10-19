.text
.globl _start
_start:
	li ra, 0
	li t0, 1024
	li t1, 25
	sw t1, 4(t0)
	li t1, 0
	lw t1, 4(t0)
	beqz t1, wrong
stop:
	nop
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
	nop
	nop
	nop
	nop
	nop
wrong:
	li ra, -1
	j stop