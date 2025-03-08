.text
.globl _start
_start:
	li a7, 17 
	la a0, hello
	ecall # println
		
	li a7, 1
	ecall # exit
	
.data
	hello: .asciz "FactoRISCoV is online."