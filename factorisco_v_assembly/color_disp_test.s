.text
    li s0, 0
	li s2, 32
	0:
	beq s0, s2, 1f
	# inner loop
	li s1, 0
	2:
	beq s1, s2, 3f
	# s0, s1: coord of pixel
	muli a0, s0, 7
	muli a1, s1, 7
	li a2, 128 # static blue
	li a7, 48
	ecall # set rgb color
	
	mv a0, s0
	mv a1, s1
	li a7, 47
	ecall # draw rgb pixel
	inc s1
	j 2b
	3:
	inc s0
	j 0b
	1:
	# exit
	li a7, 1
	ecall
	

.data

	