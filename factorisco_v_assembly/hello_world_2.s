.text
.globl _start

_start:
	# reset display
	sw zero, 10(zero)
	# cursor at (5, 0)
	li t0, 5
	sw t0, 5(zero)
	sw zero, 6(zero)
	# shift of cursor set to 8
	li t0, 8
	sw t0, 13(zero)
	# enable wrap
	#li t0, 1
	sw zero, 14(zero)
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
	# refresh display
	sw zero, 12(zero)
	# sleep
	li a0, 10
	call _sleep
	li t0, 1
	sw t0, 9(zero)
	sw zero, 12(zero)
	li a0, 10
	call _sleep
	# clear row
	sw zero, 11(zero)
	# refresh
	sw zero, 12(zero)
	halt
	nop
	nop
	nop
	nop
	nop
	nop
	nop

_sleep:
	beq a0, zero, _end_loop
	subi a0, a0, 1
	j _sleep
_end_loop:
	ret
	
	
	