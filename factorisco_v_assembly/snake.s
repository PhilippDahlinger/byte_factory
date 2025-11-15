.text
init:
	# reset color display
	li a7, 46
	ecall # cls color display

    # memory setup
	li a0, 20 # expect 20 vars needed
	li a7, 2
	ecall # sbrk
	# use s0 as our base pointer for the static memory
	mv s0, a0
	# set up initial values
	li t0, 1
	sw t0, 0(s0) # initially go right
	sw zero, 1(s0) # don't go up or down
	# head pos is 10|10
	li t0, 10
	sw t0, 2(s0)
	sw t0, 3(s0)
	# random initial food pos
	# set food color first
	la a0, food_color
	lw a0, 0(a0)
	li a7, 45
	ecall # set color
	call gen_new_food
	sw a0, 4(s0)
	sw a1, 5(s0)
	# draw pixel
	li a7, 44
	ecall # draw pixel
	# initial snake Length
	li t0, 3
	sw t0, 8(s0)
	
	# queue init
	# request initial queue memory. this will grow once more snake elements are created
	# initally, there are 3 snake elements -> request 4 * 3 = 12 words
	li a0, 12
	li a7, 2
	ecall # sbrk
	# set up the initial queue by hand, first element is the head initially
	# a0 is address of queue head element
	sw a0, 6(s0)
	addi t0, a0, 8 # address of tail element
	sw t0, 7(s0)
	# actual data inside the queue
	li t0, 10
	li t1, 10
	sw t0, 0(a0)
	sw t1, 1(a0)
	dec t0
	sw t0, 4(a0)
	sw t1, 5(a0)
	dec t0
	sw t0, 8(a0)
	sw t1, 9(a0)
	# double links
	# backward links
	sw a0, 3(a0) # self ref head
	sw a0, 7(a0)
	addi t0, a0, 4
	sw t0, 11(a0)
	# forward links
	sw t0, 2(a0)
	addi t0, t0, 4
	sw t0, 6(a0)
	sw t0, 10(a0) # self ref tail
	# print the Score label and initial score (length - 3)
	la a0, score_label
	li a7, 16
	ecall # print without new line
	# save current cursor pos for overwriting the Scores later
	li a7, 8
	ecall # get_cursor
	sw a0, 9(s0)
	sw a1, 10(s0)
	# print initial score (0)
	li a0, 0
	li a7, 19
	ecall # print_int
	
	# set initial screen pixels of snake
	la a0, snake_color
	lw a0, 0(a0)
	li a7, 45
	ecall # set color
	li a0, 10
	li a1, 10
	li a7, 44 
	ecall
	li a0, 9
	li a1, 10
	li a7, 44 
	ecall
	li a0, 8
	li a1, 10
	li a7, 44 
	ecall # set pixels
	
	
	
	# start listening to keyboard
	li a7, 22
	ecall # open_key_stream
	
	# all initialized, start game_loop
	j game_loop

############### Static Memory map ##########
# 0: current_dir_x (-1, 0, 1)
# 1: current_dir_y (-1, 0, 1)
# 2: head_pos_x
# 3: head_pos_y
# 4: food_pos_x
# 5: food_pos_y	
# 6: Link to queue head
# 7: Link to queue tail
# 8: Length of snake
# 9: display cursor row
# 10: display cursor col
############################################

############### Queue element map ##########
# 0: x_pos
# 1: y_pos
# 2: address of next element (going head -> tail)
# 3: address of prev element (going tail -> head)
############################################
game_loop:
	# 1) Process key, update current direction
	# 2) Update Head Position in static mem based on current direction
	# 3) Traverse Snake: any collisions with new head pos?
	# 4) Check if Head pos == Food pos
	#    4a) if Same pos: EAT
	#    4b) if not same pos: MOVE
	
	li a7, 24
	ecall # read_key_stream
	beqz a0, 1f
	# update current direction
	li t0, 6 # left
	bne a0, t0, 2f
	# change dir to x=-1 y=0
	li t0, -1
	sw t0, 0(s0)
	sw zero, 1(s0)
	j 1f
	2:
	li t0, 7 # right
	bne a0, t0, 2f
	# change dir to x=1 y=0
	li t0, 1
	sw t0, 0(s0)
	sw zero, 1(s0)
	j 1f
	2:
	li t0, 8 # down
	bne a0, t0, 2f
	# change dir to x=0 y=1
	li t0, 1
	sw zero, 0(s0)
	sw t0, 1(s0)
	j 1f
	2:
	li t0, 9 # up
	bne a0, t0, 1f
	# change dir to x=0 y=-1
	li t0, -1
	sw zero, 0(s0)
	sw t0, 1(s0)
	1:
	# done processing key
	
	# update head pos
	lw t0, 0(s0)
	lw t1, 1(s0)
	lw t2, 2(s0)
	lw t3, 3(s0)
	add t2, t2, t0
	add t3, t3, t1
	sw t2, 2(s0) # head posx 
	sw t3, 3(s0) # head posy
	
	# Traverse Snake: any collisions with head?
	lw t0, 6(s0) # address of head element
	# skip first head since we know that there can't be a collision
	li t1, 1 # counter for list. when length reached -> stop
	lw t4, 8(s0) # length
	lw t0, 2(t0) # first element to check
	
	2:
	beq t1, t4, 3f
	# load current element pos
	lw a0, 0(t0)
	lw a1, 1(t0)
	bne a0, t2, 4f
	bne a1, t3, 4f
	# collision! end game_loop
	j game_over
	4:
	# no colllision with current element
	inc t1
	# follow pointer
	lw t0, 2(t0)
	j 2b
	3:
	# no collision with snake
	# check collision with walls
	blt t2, zero, game_over
	blt t3, zero, game_over
	li t4, 32 # max width/height
	bge t2, t4, game_over
	bge t3, t4, game_over
	# no collision with walls
	
	# check food
	lw a0, 4(s0)
	lw a1, 5(s0)
	bne a0, t2, 5f
	bne a1, t3, 5f
	
	# EAT
	# request for new element
	# save head pos
	mv s1, t2
	mv s2, t3 
	li a0, 4
	li a7, 2
	ecall # sbrk
	# new head element in a0, all other elements are the same.
	# set new head position to a0
	sw s1, 0(a0)
	sw s2, 1(a0)
	# load current head
	lw t1, 6(s0)
	sw a0, 3(a0) # prev element is not defined, since it is the new head
	sw t1, 2(a0) # next element is old head
	# mark back reference from t1 to a0
	sw a0, 3(t1)
	# set head of queue (after mem dep resolve)
	# update length of snake
	lw t0, 8(s0)
	sw a0, 6(s0)
	# queue updated
	
	inc t0
	sw t0, 8(s0) # new length
	
	# draw new head pixel, don't remove tail
	# update color display
	la a0, snake_color
	lw a0, 0(a0)
	li a7, 45
	
	li s10, 9999
	nop
	nop
	nop
	nop
	halt
	
	ecall # set color
	mv a0, s1
	mv a1, s2
	li a7, 44
	
	ecall # draw pixel
	
	# update Score
	lw a0, 9(s0)
	lw a1, 10(s0)
	li a7, 6
	ecall # set cursor to score pos
	lw a0, 8(s0)
	li a7, 19
	subi a0, a0, 3 # initial snake was 3 long -> score is length - 3
	ecall # print_int
	
	# get new food
	# set food color first
	la a0, food_color
	lw a0, 0(a0)
	li a7, 45
	ecall # set color
	call gen_new_food
	# save it in mem
	sw a0, 4(s0)
	sw a1, 5(s0)
	# draw food pixel
	li a7, 44
	ecall # draw pixel
	j game_loop
	
	5:
	# MOVE
	# load last segment
	lw t0, 7(s0)
	# save pos to remove that pixel later
	lw s3, 0(t0)
	lw s4, 1(t0)
	# predecessor: t1
	lw t1, 3(t0)
	# set pointer to next element to itself
	sw t1, 2(t1)
	# set last element pointer to t1
	sw t1, 7(s0)
	# last element removed
	# set new head position to t0
	sw t2, 0(t0)
	sw t3, 1(t0)
	# load current head
	lw t1, 6(s0)
	sw t0, 3(t0) # prev element is not defined, since it is the new head
	sw t1, 2(t0) # next element is old head
	# mark back reference from t1 to t0
	sw t0, 3(t1)
	# set head of queue
	sw t0, 6(s0)
	# queue updated
	
	# save head pos
	mv s1, t2
	mv s2, t3
	# update color display
	la a0, snake_color
	lw a0, 0(a0)
	li a7, 45
	ecall # set color
	mv a0, s1
	mv a1, s2
	li a7, 44
	ecall # draw pixel
	# remove tail
	li a0, 0
	li a7, 45
	ecall # set color
	mv a0, s3
	mv a1, s4
	li a7,44
	ecall # draw pixel
	j game_loop


game_over:
	# todo
	li a7, 1
	ecall # exit

gen_new_food:
# returns: a0|a1: pos of new food. It makes sure that it is not inside the snake
	push ra
	0:
	# generate new random number
	li a7, 28
	ecall # random word
	# get x : 0-31
	andi t0, a0, 31
	# get y: shift and 0-31
	srai a0, a0, 5
	andi t1, a0, 31
	lw t2, 8(s0) # len
	lw t3, 6(s0) # first elem
	li t4, 0 # counter
	1:
	beq t4, t2, 3f # done, no collision
	# load element pos
	lw t5, 0(t3)
	lw t6, 1(t3)
	# check that food pos and element pos are different
	bne t0, t5, 2f
	# not the same x coord -> done
	bne t1, s1, 2f
	# not the same y coord -> done
	# both are the same -> try again
	j 0b
	2:
	# this element passed
	lw t3, 2(t3) # update pointer
	inc t4
	j 1b # check next element
	3:
	# prepare output
	mv a0, t0
	mv a1, t1
	# return
	pop ra
	ret

.data
	score_label: .asciz "Score: "
	snake_color: .word 3137097
	food_color: .word 15744550
	