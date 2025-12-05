.text
# load data
la a0, path_to_data
li a7, 40
ecall # fs_load
# a0: pointer to file in RAM
# a1: length of file in RAM (not needed for our stuff)

# check if file could be loaded
bge a0, zero, 1f
# error case
la a0, loading_failed
li a7, 17
ecall # println
li a7, 1
ecall # exit
1:

mv s9, a0
li s10, 24 
lw s11, 0(s9)

la a0, loaded_data
li a7, 17
ecall # println

# s0: RAM start address
# s1: temp
# s2: current row to build
# s3: temp
# s4/s5: row counter
# s6: global result counter
# program starts here

call preprocess
li s6, 0

li s4, 0
li s5, 140
0:
beq s4, s5, 1f
# print index
li a7, 8
ecall # get cursor
li a1, 0
li a7, 6
ecall # set cursor to start of line
mv a0, s4
li a7, 19
ecall

# row idx s4, check the 5 words
muli t0, s4, 5
addi t0, t0, 5 # address offset of primary word
add s1, t0, s0 # address of primary first word
# word 0
lw a0, -5(s1)
lw a1, 0(s1)
lw a2, 5(s1)
call check_word
# word 1
lw a0, -4(s1)
lw a1, 1(s1)
lw a2, 6(s1)
call check_word
# word 2
lw a0, -3(s1)
lw a1, 2(s1)
lw a2, 7(s1)
call check_word
# word 3
lw a0, -2(s1)
lw a1, 3(s1)
lw a2, 8(s1)
call check_word
# word 4
lw a0, -1(s1)
lw a1, 4(s1)
lw a2, 9(s1)
call check_word
inc s4
j 0b
1:
la a0, password_str
li a7, 16
ecall
mv a0, s6
li a7, 19
ecall
halt



check_word:
push ra
# a0: word above
# a1: primary word to check
# a2: word below
# updates counter, no returns
li t0, 1
li t1, 31

0:
beq t0, t1, 1f
# load primary bit to check if paper is there
sra t2, a1, t0
andi t2, t2, 1
beqz t2, 2f
# compute the number of nbs
# nb counter
li a3, 0
# top left
addi t3, t0, 1
sra t2, a0, t3
andi t2, t2, 1
add a3, a3, t2
# top center
addi t3, t0, 0
sra t2, a0, t3
andi t2, t2, 1
add a3, a3, t2
# top right
addi t3, t0, -1
sra t2, a0, t3
andi t2, t2, 1
add a3, a3, t2
# center left
addi t3, t0, 1
sra t2, a1, t3
andi t2, t2, 1
add a3, a3, t2
# center right
addi t3, t0, -1
sra t2, a1, t3
andi t2, t2, 1
add a3, a3, t2
# bot left
addi t3, t0, 1
sra t2, a2, t3
andi t2, t2, 1
add a3, a3, t2
# bot center
addi t3, t0, 0
sra t2, a2, t3
andi t2, t2, 1
add a3, a3, t2
# bot right
addi t3, t0, -1
sra t2, a2, t3
andi t2, t2, 1
add a3, a3, t2

# check <4
slti a3, a3, 4
# beqz a3, 5f
# push t0
# push t1
# push t2
# push t3
# push a0
# push a1
# push a2
# push a3
# mv a0, t0
# li a7, 19
# ecall
# pop a3
# pop a2
# pop a1
# pop a0
# pop t3
# pop t2
# pop t1
# pop t0
# 5:
add s6, s6, a3 # update
2:
inc t0
j 0b
1:
pop ra
ret # counter updated


preprocess:
	push ra
	# request RAM
	# 5 * 142 rows
	li a0, 710
	li a7, 2
	ecall # sbrk
	mv s0, a0
	# first row is completely zero
	sw zero, 0(s0)
	sw zero, 1(s0)
	sw zero, 2(s0)
	sw zero, 3(s0)
	sw zero, 4(s0)
	addi s1, s0, 5
	
	li s4, 0
	li s5, 140
	0:
	beq s4, s5, 1f
	# build a row, first 2 bit is given as an argument in a1, a2
	li a1, 0
	li a2, 0
	call build_word # last bit is in a1 and a2
	sw a0, 0(s1)
	call build_word
	sw a0, 1(s1)
	call build_word
	sw a0, 2(s1)
	call build_word
	sw a0, 3(s1)
	call build_word
	sw a0, 4(s1)
	addi s1, s1, 5
	inc s4
	j 0b
	1:
	# last row is zero
	sw zero, 0(s1)
	sw zero, 1(s1)
	sw zero, 2(s1)
	sw zero, 3(s1)
	sw zero, 4(s1)
	pop ra
	ret
	
	

build_word:
# args:
# a1: initial bit
# returns: a0: word built
#          a1: second to last bit (0 or 1)
#          a2: last bit
	push ra
	push s1
	push s2
	push s3
	mv s2, a1 # set initial bits
	slli s2, s2, 1
	add s2, s2, a2
	li s1, 2
	li s3, 32
	0:
	beq s1, s3, 1f
	call read_next_char
	# either "." = 46, or "@" = 64, or "\n" = 10
	li t0, 46
	bne a0, t0, 2f
	# add 0 to word
	slli s2, s2, 1
	mv a1, a2 # second to last bit
	li a2, 0
	j 4f
	2:
	li t0, 64
	bne a0, t0, 3f
	# add 1 to word
	slli s2, s2, 1
	addi s2, s2, 1
	mv a1, a2 # second to last bit
	li a2, 1 # last bit
	j 4f
	3:
	# has to be new line
	# shift by that much so that current word is left aligned
	sub t0, s3, s1
	sll s2, s2, t0
	j 1f
	4:
	inc s1
	j 0b
	1:
	mv a0, s2
	pop s3
	pop s2
	pop s1
	pop ra
	ret


read_next_char:
	# no input, but requires state s9-s11 to be correctly initialized and not-altered
	# returns: a0: next char
	# shift current word by s10 amount
	sra a0, s11, s10
	andi a0, a0, 255
	subi s10, s10, 8
	blt s10, zero, 1f
	ret
	1:
	# load next word
	inc s9
	lw s11, 0(s9)
	li s10, 24
	ret
	

.data
	path_to_data: .asciz "/DATA/2504"
	loaded_data: .asciz "Data loaded."
	loading_failed: .asciz "Data could not be loaded. Wrong path?"
	password_str: .asciz "Password: "