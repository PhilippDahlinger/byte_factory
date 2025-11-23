.text
	# load data
	li t0, 70144
    addi s1, t0, 150
	addi s2, t0, 160
	0:
	beq s1, s2, 1f
	lw s3, 0(s1)
	# print
	mv a0, s1
	li a7, 19
	ecall
	li a0, 32
	li a7, 18
	ecall #print " "
	mv a0, s3
	li a7, 19
	ecall
	li a7, 33
    ecall
    inc s1
	j 0b
	1:
	li a7, 1
	ecall



.data