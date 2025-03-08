.text
.globl _start
_start:
	# create string which contains all symbols
	li t0, 1000 # start address of string
	li t1, 30 # data
	li t2, 128 # last code
	0:
	beq t1, t2, 1f
	sw t1, 0(t0)
	inc t0
	inc t1
	j 0b
	1:
	sw zero, 0(t0) # end string with 0 code
	
	# set font: wrap enable and stride 1
	li a7, 9
	li a0, 0 # font
	li a1, 1 # stride
	li a2, 1 # wrap lines
	ecall
	
	li a7, 17 
	li a0, 1000  # load string
	ecall # println
		
	li a7, 1
	ecall # exit
	
.data