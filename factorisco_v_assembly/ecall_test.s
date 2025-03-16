.text
.globl _start
_start:
	call str_to_int_test
	li a7, 1
	ecall # exit


str_to_int_test:
	push ra
	li a0, 0
	li a1, 15 # max length
	li a7, 26
	ecall # input
	li a7, 31
	ecall # str_to_int
	# cube output to prove its a number
	mul t0, a0, a0
	mul t0, t0, a0
	mv a0, t0
	li a7, 19
	ecall # print int
	pop ra
	ret

rand_int_test:
	push ra
	push s0
	li s0, 10
	0:
	li a0, 10000
	li a7, 27
	ecall # rand_int
	li a7, 19
	ecall # print int
	li a7, 25
	ecall # wait for next key
	beq a0, s0, 0b
	pop s0
	pop ra
	ret

msb_test:
	push ra
	li a0, 5
	li a7, 34
	ecall # msb
	mv s10, a0
	li a7, 19
	ecall # print int
	li a0, 10
	li a7, 18 
	ecall # print new line
	pop ra
	ret

print_int_test:
	push ra
	li a7, 28
	ecall # random word
	li a7, 19
	ecall # print int
	li a0, 10
	li a7, 18 
	ecall # print new line
	pop ra
	ret


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
	sub s3, s2, s1
	sub s4, s1, s0
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
