.text
.globl _start
_start:
	call msb_test
	li a7, 1
	ecall # exit
	
msb_test:
	push ra
	li a0, 2
	call msb
	#li a7, 34
	#ecall # msb
	li a7, 19
	ecall # print int
	pop ra
	ret

msb:
    li a1, -1           # msb = -1
    li a2, 0            # L = 0
    li a3, 32           # R = 32 (assuming 32-bit numbers, adjust for 64-bit)
	li t1, 1           # t1 = 1
    
	0:
    bgt a2, a3, 1f    # while L <= R

    add a4, a2, a3      # mid = (L + R) / 2
    divi a4, a4, 2      

    sll t0, t1, a4     # 1 << mid
    ble t0, a0, 2f  # if (1 << mid) <= n, go right

    addi a1, a4, -1    # msb = mid - 1
    addi a3, a4, -1    # R = mid - 1
	push a0
	mv a0, a1
	li a7, 19
	ecall
	pop a0
    j 0b

	2:
    addi a2, a4, 1     # L = mid + 1
	push a0
	mv a0, a2
	li a7, 19
	ecall
	pop a0
    j 0b

	1:
    mv a0, a1          # return msb in a0
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
	li a0, 0
	li a7, 2
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
