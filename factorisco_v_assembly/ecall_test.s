.text
.globl _start
_start:
	li sp, 33000  # init sp
	
	li a7, 15 
	ecall # cls
	
	li a7, 17 
	la a0, hello
	ecall # println
	
	halt
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	
.data
	hello: .asciz "Hello World!"