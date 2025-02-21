.text
.globl _start

_start:	
	li s1, 1
	li s2, 1
	li t1, 1
	li t2, 10
loop:
	beq t1, t2, end_loop 
	add s1, s1, s2
	add s2, s1, s2
	addi t1, t1, 1
	j loop
end_loop:
	halt
	nop
	nop
	nop
	nop
.data
	Here
	Random stuff
	is there
