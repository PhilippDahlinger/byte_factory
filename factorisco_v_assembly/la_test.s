.text
.globl _start
_start:
	li t0, 500000
	la t1, num1
	lw t1, 0(t1)
	la t2, array1
	lw t3, 0(t2)
	lw t4, 1(t2)
	lw t5, 2(t2)
	# reset display
	sw zero, 10(zero)
	# cursor at (5, 0)
	li t0, 5
	sw t0, 5(zero)
	sw zero, 6(zero)
	# shift of cursor set to 1
	li t0, 1
	sw t0, 13(zero)
	# enable wrap
	li t0, 1
	sw t0, 14(zero)
	# fdr to 0 to show first line
	sw zero, 9(zero)
	# refresh display
	sw zero, 12(zero)
	la t0, str2
	lw t1, 0(t0)
	sw t1, 7(zero)
	lw t1, 1(t0)
	sw t1, 7(zero)
	lw t1, 2(t0)
	sw t1, 7(zero)
	lw t1, 3(t0)
	sw t1, 7(zero)
	lw t1, 4(t0)
	sw t1, 7(zero)
	
	# refresh display
	sw zero, 12(zero)
	
	halt
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	
.data
num1: .word 42
array1: .word 23, 24, 25
str1: .ascii "hi"
str2: .asciz "hello"
	