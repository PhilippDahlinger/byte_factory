.text
.globl _start
_start:
	call sleep_test
	li a7, 1
	ecall # exit


sleep_test:
	push ra
	li a7, 4
	ecall # get_time
	mv s0, a0
	li a7, 4
	ecall # get_time
	mv s1, a0
	li a0, 200
	li a7, 5
	ecall # sleep for x cycles
	li a7, 4
	ecall # get_time
	mv s2, a0
	pop ra
	ret
	
input_test:
	push ra
	li a0, 0
	li a1, 40
	li a7, 26
	ecall # input
	
	li a7, 17
	ecall # print string
	pop ra
	ret
	
wait_for_key_test:
	push ra
	# s0: key code for enter, exit in that case
	li s0, 10
	
	li a7, 22
	ecall # open key stream
	
	0:
	# wait for key
	li a7, 25
	ecall # wait_for_key
	
	beq a0, s0, 1f
	
	li a7, 18 
	ecall # print_char
	
	j 0b	
	1:
	li a7, 23
	ecall # close key stream
	pop ra
	ret

sbrk_test:
	push ra
	li a7, 2
	li a0, 3
	ecall # sbrk for 3 words
	
	li t0, 23
	sw t0, 0(a0)
	li t0, 24
	sw t0, 1(a0)
	li t0, 25
	sw t0, 2(a0)
	
	lw s0, 0(a0)
	lw s1, 1(a0)
	lw s2, 2(a0)
	
	li a7, 2
	li a0, 1
	ecall # sbrk for 1 word
	
	li t0, 50
	sw t0, 0(a0)
	
	lw s3, 0(a0)
	
	
	
	pop ra
	ret
	
.data
