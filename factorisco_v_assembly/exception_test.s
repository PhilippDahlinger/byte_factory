.text
.globl _start
_start:
	li t0, 1
	sw t0, 14(zero)
	# div t1, t0, zero
_loop:
	j _loop
	