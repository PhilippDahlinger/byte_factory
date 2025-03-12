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
	li a7, 1
	ecall # exit

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
	
	# saved variables
	li s0, 0 # s0: row * game dim + col of cursor
	li s1, 0 # cursor postion saved for quick access
	li s2, 0
	# s3/s4 address of the status and the bomb arrays
	# s5/s6: temps which are save after ecalls
	li s7, 0 # animation state, switches between 0 and 1
	li s8, 1 # constant 1 for stuff
	li s9, 3 # game dim
	mul s10, s9, s9 # total size of field
	
	# memory maps
	# bombs
	mv a0, s10
	li a7, 2
	ecall  # sbrk
	push a0 # save ref
	li a1, 0
	call init_field
	# add bombs
	# get bomb ref back from stack
	lw s5, 0(sp)
	li s6, 5 # bomb counter, always >0, so can use a do-while loop
	0:
	mv a0, s10
	li a7, 27
	ecall # randint of the array size
	add t0, a0, s5 # array access
	lw t1, 0(t0) # bombs[t0]
	beq t1, s8, 0b # start again if bomb is already there
	# place bomb
	sw s8, 0(t0)
	dec s6
	bne s6, zero, 0b # go back to place next bomb
	
	# status 
	mv a0, s10
	li a7, 2
	ecall  # sbrk
	push a0 # save ref
	li a1, 136
	call init_field
	
	pop s3 # status field address
	pop s4 # bomb field address
	
	# DEBUG: draw bombs in status
	li t0, 0
	add t2, s3, s10 # end of status array
	0:
	add t1, s3, t0
	beq t1, t2, 1f
	add t3, s4, t0 # bomb index
	lw t3, 0(t3) # actual bomb bool
	beq t3, s8, 2f # if 1: draw bomb in status
	3:
	inc t0 
	j 0b
	2:
	li t3, 131 # create diamond bomb char
	sw t3, 0(t1) # bomb char in status reg
	j 3b
	1:
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
	str_init_field: .word 136, 136, 136, 10
	.word 136, 136, 136, 10
	.word 136, 136, 136, 0 # end of string is 0