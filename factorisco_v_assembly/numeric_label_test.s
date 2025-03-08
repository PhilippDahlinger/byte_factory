.text
.globl _start
_start:
	li t0, 10
	1:
	beqz t0, 2f
	muli t1, t0, 2
	subi t0, t0, 1
	j 1b
	2:
	li t1, 50
	2:
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
	