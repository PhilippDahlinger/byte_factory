.text
.globl _start

_start:
	# reset display
	sw zero, 10(zero)
	# cursor at (0, 0)
	sw zero, 5(zero)
	sw zero, 6(zero)
	# fdr to 0 to show first line
	sw zero, 9(zero)
	li t0, 72 # H
	sw t0, 7(zero)
	li t0, 69 # E
	sw t0, 7(zero)
	li t0, 76 # L
	sw t0, 7(zero)
	li t0, 76 # L
	sw t0, 7(zero)
	li t0, 79 # O
	sw t0, 7(zero)
	li t0, 32 # 
	sw t0, 7(zero)
	li t0, 87 # W 
	sw t0, 7(zero)
	li t0, 79 # O
	sw t0, 7(zero)
	li t0, 82 # R
	sw t0, 7(zero)
	li t0, 76 # L
	sw t0, 7(zero)
	li t0, 68 # D
	sw t0, 7(zero)
	halt
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	