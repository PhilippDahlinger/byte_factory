.text
init:
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
	call gen_new_food
	sw a0, 4(s0)
	sw a1, 5(s0)
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
	sw a1, 10(s1)
	# print initial score (0)
	li a0, 0
	li a7, 19
	ecall # print_int
	
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
	
	1:
	# done processing key


game_over:
	# todo
	li a7, 1
	ecall # exit


gen_new_food:
# a0: xpos of current head -> move to s0
# a1: ypos of current head -> move to s1
# returns: a0|a1: pos of new food. It makes sure it is not extremely close (TODO) to the head position
	push s0
	push s1
	push ra
	mv s0, a0
	mv s1, a1
	0:
	# generate new random number
	li a7, 28
	ecall # random word
	# get x : 0-31
	andi t0, a0, 31
	# get y: shift and 0-31
	srai a0, a0, 5
	andi t1, a0, 31
	# check that it is not the head pos
	# TODO: check a region around the head
	bne t0, s0, 1f
	# not the same x coord -> done
	bne t1, s1, 1f
	# not the same y coord -> done
	# both are the same -> try again
	j 0b
	1:
	# prepare output
	mv a0, t0
	mv a1, t1
	# return
	pop ra
	pop s1
	pop s0
	ret

.data
	score_label: .asciz "Score: "