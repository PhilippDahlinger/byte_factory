.text
.globl _start
_start:
	call init
	
	game_loop:
	# animation
	# update animation state
	xori s7, s7, 1
	beq s7, zero, 1f # erase animation
    # draw animation
	li a0, 128 # full block
	li a7, 18
	ecall
	j 2f
	1:
	# erase animation
	add t0, s3, s0 # array address + offset
	lw a0, 0(t0)  # load game state of that block
	li a7, 18
	ecall
	# process inputs
	2:
	li a7, 24
	ecall # get next key
	li t0, 11
	beq a0, t0, stop
	li t0, 6
	beq a0, t0, 0f # left
	li t0, 7
	beq a0, t0, 1f # right
	li t0, 8
	beq a0, t0, 2f # down
	li t0, 9
	beq a0, t0, 3f # up
	li t0, 32
	beq a0, t0, space_event # space
	j game_loop # none of these keys
	# key event handlings
	# directions:
	0:
	li a0, 0
	li a1, -1
	j cursor_movement
	1:
	li a0, 0
	li a1, 1
	j cursor_movement
	2:
	li a0, 1
	li a1, 0
	j cursor_movement
	3:
	li a0, -1
	li a1, 0
	j cursor_movement
	space_event:
	# check if bomb is in current field
	add t0, s4, s0
	lw t1, 0(t0)
	beq t1, zero, 1f
	# bomb was found -> loose the game
	# draw bomb in current field
	li a0, 131
	li a7, 18
	ecall # print_char
	j stop # end game
	1:
	# update status to display number
	call update_status
	# reset real cursor to current position
	mv a0, s1
	mv a1, s2
	li a7, 6
	ecall
	j game_loop
	

	
	cursor_movement:
	# new potential cursor position
	add s5, s1, a0
	add s6, s2, a1
	
	# check if it is in bounds
	blt s5, zero, 1f
	blt s6, zero, 1f
	bge s5, s9, 1f
	bge s6, s9, 1f
	# delete current animation
	add t0, s3, s0 # array address + offset
	lw a0, 0(t0)  # load game state of that block
	li a7, 18
	ecall # draw original game state
	
	# set actual cursor position
	mv s1, s5
	mv s2, s6	
	# compute array index row*game_dim + col
	mul s0, s1, s9
	add s0, s0, s2
	mv a0, s5
	mv a1, s6
	li a7, 6 
	ecall # set cursor abs
	1: # skip everything if out of bounds
	j game_loop
	
	stop:
	li a7, 23
	ecall # close key stream
	# move cursor to the end of the field
	mv a0, s1
	li a1, 0
	li a7, 6
	ecall # set cursor abs
	li a7, 1
	ecall # exit

update_status:
	# computes the number of current cursor position and saves it in the status array
	push ra
	push s5 # recursive stuff: old s5 value needs to be saved
	li s5, 0 # accumulator of the status
	
	# update real cursor
	mv a0, s1
	mv a1, s2
	li a7, 6
	ecall
	# set border flags 0: is close to border, 1: is a binnengebiet
	slt t2, zero, s1 # t0 = (s1 > 0), for top row
	slt t3, zero, s2 # for left col
	subi t0, s9, 1  
	slt t4, s1, t0 # t4 = (s1 < dim - 1), for bot row
	slt t5, s2, t0 # for right col
	
	
	add t0, s4, s0 # current bomb index
	# check out all 8 nbs
	lw t1, -1(t0) # center left
	mul t1, t1, t3
	add s5, s5, t1
	lw t1, 1(t0) # center right
	mul t1, t1, t5
	add s5, s5, t1
	# jump over top row if top flags is 0
	beqz t2, 1f
	sub t0, t0, s9 # go one row up
	lw t1, -1(t0) # top left
	mul t1, t1, t3
	add s5, s5, t1
	lw t1, 0(t0) # top center
	add s5, s5, t1
	lw t1, 1(t0) # top right
	mul t1, t1, t5
	add s5, s5, t1
	add t0, t0, s9
	1:
	# jump over bot row if bot flag is 0
	beqz t4, 2f
	# go 1 row down
	add t0, t0, s9
	lw t1, -1(t0) # bottom left
	mul t1, t1, t3
	add s5, s5, t1
	lw t1, 0(t0) # bottom center
	add s5, s5, t1
	lw t1, 1(t0) # bottom right
	mul t1, t1, t5
	add s5, s5, t1
	2:
	# s5 contains the number <= 8 of all bombs in nbh
	# update status, save ascii code of number
	beqz s5, 3f # depth first search if zero was discovered
	addi a0, s5, 48 # ascii code
	add t0, s3, s0 # current status index
	sw a0, 0(t0)
	li a7, 18
	ecall # print char
	pop s5 
	pop ra
	ret
	
	3:
	# set a " " to the status reg
	li a0, 32
	add s6, s3, s0 # current status index
	sw a0, 0(s6)
	# expand all neighbors which are not explored
	# save current status, could do it with multiple pushes, but this saves a lot of ticks
	li s5, 136
	addi sp, sp, -8
	sw s0, -7(sp)
	sw s1, -6(sp)
	sw s2, -5(sp)
	sw s6, -4(sp)  # all these are modified
	# put t2-t5 on the stack as local var to make it persistent between function calls 
	sw t2, -3(sp)
	sw t3, -2(sp)
	sw t4, -1(sp)
	sw t5, 0(sp)
	

	li a0, 32
	li a7, 18
	ecall # print char " ". Needed for recursion reasons, since other blocks are not updated by the game loop
	
	lw t1, -1(s6) # center left
	lw t3, -2(sp)
	mul t1, t1, t3 
	bne t1, s5, 1f
	# recursive call, update new index
	addi s0, s0, -1
	addi s2, s2, -1
	call update_status
	# reset to middle pos
	lw s0, -7(sp)
	lw s2, -5(sp)
	
	1:
	lw t1, 1(s6) # center right
	lw t5, 0(sp) # now it has to come from the stack
	mul t1, t1, t5
	bne t1, s5, 1f
	# recursive call, correct new index
	addi s0, s0, 1
	addi s2, s2, 1
	call update_status
	lw s0, -7(sp)
	lw s2, -5(sp)
	
	1:
	# jump over top row if top flags is 0
	lw t2, -3(sp)
	beqz t2, 2f
	sub s6, s6, s9 # go one row up
	sub s0, s0, s9 # array index will also shift
	lw t1, -1(s6) # top left
	lw t3, -2(sp)
	mul t1, t1, t3
	bne t1, s5, 1f
	# recursive call, correct new index
	addi s0, s0, -1
	addi s1, s1, -1
	addi s2, s2, -1
	call update_status
	addi s0, s0, 1 # reset s0 to the one row up status
	lw s1, -6(sp)
	lw s2, -5(sp)	
	
	1:
	lw t1, 0(s6) # top center
	bne t1, s5, 1f
	# recursive call, correct new index
	addi s1, s1, -1
	call update_status
	lw s1, -6(sp)
	
	1:
	lw t1, 1(s6) # top right
	lw t5, 0(sp) # now it has to come from the stack
	mul t1, t1, t5
	bne t1, s5, 1f
	# recursive call, correct new index
	addi s0, s0, 1
	addi s1, s1, -1
	addi s2, s2, 1
	call update_status
	addi s0, s0, -1
	lw s1, -6(sp)
	lw s2, -5(sp)
	1:
	add s6, s6, s9
	add s0, s0, s9
	2:
	# jump over bot row if bot flag is 0
	lw t4, -1(sp)
	beqz t4, 2f
	add s6, s6, s9 # go one row down
	add s0, s0, s9 # array index will also shift
	lw t1, -1(s6) # bottom left
	lw t3, -2(sp)
	mul t1, t1, t3
	bne t1, s5, 1f
	# recursive call, correct new index
	addi s0, s0, -1
	addi s1, s1, 1
	addi s2, s2, -1
	call update_status
	addi s0, s0, 1 # reset s0 to the one row down status
	lw s1, -6(sp)
	lw s2, -5(sp)	
	
	1:
	lw t1, 0(s6) # bot center
	bne t1, s5, 1f
	# recursive call, correct new index
	addi s1, s1, 1
	call update_status
	lw s1, -6(sp)
	
	1:
	lw t1, 1(s6) # bot right
	lw t5, 0(sp) # now it has to come from the stack
	mul t1, t1, t5
	bne t1, s5, 1f
	# recursive call, correct new index
	addi s0, s0, 1
	addi s1, s1, 1
	addi s2, s2, 1
	call update_status
	addi s0, s0, 1
	lw s1, -6(sp)
	lw s2, -5(sp)
	1:
	sub s6, s6, s9
	sub s0, s0, s9
	2:
	# reset stack

	lw s0, -7(sp)
	lw s1, -6(sp)
	lw s2, -5(sp)
	lw s6, -4(sp)
	addi sp, sp, 8
	pop s5 # from way at the beginning
	pop ra
	ret
	

init:
	push ra
	li a7, 15
	ecall # cls
	li a0, 0
	li a1, 0
	li a7, 6
	ecall # set cursor to 0,0
	li a0, 0
	li a7, 11
	ecall #set fdr to 0
	
	la a0, str_init_field
	li a7, 16
	ecall # print initial field with # signs
	
	# saved variables
	li s0, 0 # s0: row * game dim + col of cursor
	li s1, 0 # cursor postion saved for quick access
	li s2, 0
	# s3/s4 address of the status and the bomb arrays
	# s5/s6: temps which are save after ecalls
	li s7, 0 # animation state, switches between 0 and 1
	li s8, 1 # constant 1 for stuff
	li s9, 9 # game dim
	mul s10, s9, s9 # total size of field
	
	# memory maps
	# bombs
	# mv a0, s10  <- Correct line
	li a0, 256  # debug line
	li a7, 2
	ecall  # sbrk
	push a0 # save ref
	li a1, 0
	call init_field
	# add bombs
	# get bomb ref back from stack
	lw s5, 0(sp)
	li s6, 10 # bomb counter
	# print total number of bombs
	li a0, 0
	addi a1, s9, 1 # 1 field right to the game
	li a7, 6
	ecall # set cursor abs
	la a0, str_bombs
	li a7, 16
	ecall # print
	mv a0, s6
	li a7, 19
	ecall # print int (bombs)
	
	0:
	beq s6, zero, 1f
	mv a0, s10
	li a7, 27
	ecall # randint of the array size
	add t0, a0, s5 # array access
	lw t1, 0(t0) # bombs[t0]
	beq t1, s8, 0b # start again if bomb is already there
	# place bomb
	sw s8, 0(t0)
	dec s6
	j 0b # go back to place next bomb
	1:
	# status 
	# mv a0, s10  <- Correct line
	li a0, 256  # debug line
	li a7, 2
	ecall  # sbrk
	push a0 # save ref
	li a1, 136
	call init_field
	
	pop s3 # status field address
	pop s4 # bomb field address
	
	li a0, 0
	li a1, 0
	li a7, 6
	ecall # set cursor to 0,0 again
	
	li a0, 0
	li a1, 0 # no stride
	li a2, 0
	li a7, 9
	ecall # set font to not use stride, important for animation
	
	li a7, 22
	ecall # open key stream
	
	# DEBUG: draw bombs in status
	# li t0, 0
	# add t2, s3, s10 # end of status array
	# 0:
	# add t1, s3, t0
	# beq t1, t2, 1f
	# add t3, s4, t0 # bomb index
	# lw t3, 0(t3) # actual bomb bool
	# beq t3, s8, 2f # if 1: draw bomb in status
	# 3:
	# inc t0 
	# j 0b
	# 2:
	# li t3, 131 # create diamond bomb char
	# sw t3, 0(t1) # bomb char in status reg
	# j 3b
	# 1:
	# END DEBUG
	
	pop ra
	ret

init_field:
	# a0: memory start, s10: size of field
	# a1: initial value
	# t0: end of array
	add t0, a0, s10
	0:
	beq a0, t0, 1f
	sw a1, 0(a0)
	inc a0
	j 0b
	1:
	ret

.data
	# have to make sure that this matches with the game dim
	# define string like this, since the char 136 does not exist normally...
	# str_init_field: .word 136, 136, 136, 136,10
	# .word 136, 136, 136, 136, 10
	# .word 136, 136, 136, 136, 10
	# .word 136, 136, 136, 136,0
	
	str_init_field: .word 136, 136, 136, 136, 136, 136, 136, 136, 136, 10
	.word 136, 136, 136, 136, 136, 136, 136, 136, 136, 10
	.word 136, 136, 136, 136, 136, 136, 136, 136, 136, 10
	.word 136, 136, 136, 136, 136, 136, 136, 136, 136, 10
	.word 136, 136, 136, 136, 136, 136, 136, 136, 136, 10
	.word 136, 136, 136, 136, 136, 136, 136, 136, 136, 10
	.word 136, 136, 136, 136, 136, 136, 136, 136, 136, 10
	.word 136, 136, 136, 136, 136, 136, 136, 136, 136, 10
	.word 136, 136, 136, 136, 136, 136, 136, 136, 136, 0
	
	
	str_bombs: .asciz "Bombs: "