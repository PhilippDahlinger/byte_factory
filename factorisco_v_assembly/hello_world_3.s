.text
.globl _start
_start:
	la a0, welcome
	li a7, 17
	ecall # println
	li a7, 1
	ecall # exit
.data
	welcome: .asciz "Hello ROM 3"