# ECALL implementation
.text
main:
	push ra
	li t1, 34  # last valid ECALL code
	# check for valid ECALL code
	bgt a7, t1, invalid_input
	blt a7, zero, invalid_input
	
	la t0, jump_table  
	add a7, a7, t0
	# execute ECALL
	jalr ra, 0(a7)
	# remove kernel access. Since ECALL adds +1 to the kernel address in hardware, decrease it by 1. -> Same access as before the ecall instruction
	lw t0, 15(zero)
	pop ra  # solve mem dependency
	dec t0
	sw t0, 15(zero)
	ret
	
jump_table:
	# indirect jump to correct function. the ret will bring it back to the main function
	jal zero, reset #0
	jal zero, exit #1
	jal zero, sbrk #2
	jal zero, raise_exception #3
	jal zero, get_time #4
	jal zero, sleep #5
	jal zero, set_cursor #6
	jal zero, set_cursor_rel #7
	jal zero, get_cursor #8
	jal zero, set_font #9
	jal zero, get_font #10
	jal zero, set_fdr #11
	jal zero, set_fdr_rel #12
	jal zero, get_fdr #13
	jal zero, clear_row #14
	jal zero, cls #15
	jal zero, print #16
	jal zero, println #17
	jal zero, print_char #18
	jal zero, print_int #19
	jal zero, cprint #20
	jal zero, cprint_ln #21
	jal zero, open_key_stream #22
	jal zero, close_key_stream #23
	jal zero, read_key_stream #24
	jal zero, wait_for_next_key #25
	jal zero, input #26
	jal zero, rand_int #27
	jal zero, rand_word #28
	jal zero, str_to_cstr #29
	jal zero, cstr_to_str #30
	jal zero, str_to_int #31
	jal zero, int_to_str #32
	jal zero, set_cursor_to_next_line # 33
	jal zero, msb # 34
	
invalid_input:
	# TODO
	call raise_exception
	
reset:
	# not used
	ret
	
exit:
	push ra
	# user program ends, go back to os
	# need to reset stack, set ra correctly on the stack, increment kernel mode to be in kernel mode after ecall decrements it again
	li sp, 33000  # reset sp
	li t0, 1000 # reset value of sbrk pointer
	sw t0, 256(zero) # address 256 = sbrk pointer
	# inc kernel
	lw t0, 15(zero)
	inc t0
	sw t0, 15(zero)
	li a0, 0 # font
	li a1, 1 # stride
	li a2, 0 # no wrap
	call set_font
	call set_cursor_to_next_line
	call get_cursor
	subi a0, a0, 10
	call set_fdr # make print statement at the bottom of the screen to see the output easily
	
	
	pop ra # stack clean up
	# hardcoded entry point of OS program in kernel ROM #2
	li t0, 139776
	jalr zero, 0(t0)
	ret

sbrk:
	lw t0, 256(zero) # load old sbrk pointer
	add t1, t0, a0 # update
	# check for invalid state
	li t2, 1000
	blt t1, t2, 1f # if < 1000: memory regime of kernel -> throw exception
	bge t1, sp, 1f # check if sbrk is in stack regime. sp can grow into sbrk though currently
	sw t1, 256(zero)
	# return old sbrk pointer
	mv a0, t0 # old sbrk pointer
	ret
	1:
	# TODO: raise memory exception, or StackOverFlow exception!
	call raise_exception
	ret

raise_exception:
	li s10, -1
	li s11, -1
	halt
	nop
	nop
	nop
	nop
	nop
	nop
	ret

get_time:
	lw a0, 16(zero)
	ret

sleep:
	# 17 cycles to get here, 14 after ret
	subi a0, a0, 40  # ballpark after test
	divi a0, a0, 5 # one loop takes 5 cycles, since jump needs 3 cycles
	0:
	blt a0, zero, 1f
	dec a0
	j 0b
	1:
	ret

set_cursor:
	sw a0, 5(zero)
	sw a1, 6(zero)
	ret
	
set_cursor_rel:
	lw t0, 5(zero)
	lw t1, 6(zero)
	add a0, a0, t0
	add a1, a1, t1
	sw a0, 5(zero)
	sw a1, 6(zero)
	ret
	
get_cursor:
	lw a0, 5(zero)
	lw a1, 6(zero)
	ret

set_font:
	# sets font, stride, and wrap
	sw a0, 8(zero)
	sw a1, 13(zero)
	sw a2, 14(zero)
	ret
	
get_font:
	# gets font, stride, and wrap
	lw a0, 8(zero)
	lw a1, 13(zero)
	lw a2, 14(zero)
	ret

set_fdr:
	sw a0, 9(zero)
	# refresh
	sw zero, 12(zero)
	ret
	
set_fdr_rel:
	lw t0, 9(zero)
	add a0, a0, t0
	sw a0, 9(zero)
	# refresh
	sw zero, 12(zero)
	ret
	
get_fdr:
	lw a0, 9(zero)
	ret

clear_row:
	sw zero, 11(zero)
	# refresh
	sw zero, 12(zero)
	ret

cls:
	sw zero, 10(zero)
	# refresh
	sw zero, 12(zero)
	ret

print:
    # TODO: FDR movements
	# a0: start address
	# t0: char index, starts at a0
	# t1: data reg
	# t2: check for \n = 10
	mv t0, a0
	li t2, 10
	0:
	lw t1, 0(t0)
	beqz t1, 1f
	# check for \n (and possible \t?). Solve this in hardware maybe?
	beq t1, t2, 2f
	# print char
	sw t1, 7(zero)
	inc t0
	j 0b
	2:
	# \n case, move cursor one row, set col to 0
	lw t3, 5(zero)
	sw zero, 6(zero) # solve data dependency by adding the sw here
	inc t3
	sw t3, 5(zero)
	# repeat end of loop to save a jump -> faster
	inc t0
	j 0b
	1:
	# refresh
	sw zero, 12(zero)
	ret
	
println:
	push ra
	call print
	# move cursor
	lw t3, 5(zero)
	sw zero, 6(zero) # solve data dependency by adding the sw here
	inc t3
	sw t3, 5(zero)
	pop ra
	ret

print_char:
	# check for \n
	li t2, 10
	beq a0, t2, 2f
	# print char
	sw a0, 7(zero)
	# refresh
	sw zero, 12(zero)
	ret
	2:
	# \n case, move cursor one row, set col to 0
	lw t3, 5(zero)
	sw zero, 6(zero) # solve data dependency by adding the sw here
	inc t3
	sw t3, 5(zero)
	# refresh
	sw zero, 12(zero)
	ret
	
print_int:
	push ra
	call int_to_str
	# string starts from address a0
	call print
	
	li a0, -12 # free 12 characters long, for now this is fixed in int_to_str
	call sbrk
	pop ra
	ret

cprint:
	ret

cprint_ln:
	ret

open_key_stream:
	li t0, 1
	sw t0, 3(zero)
	ret

close_key_stream:
	sw zero, 3(zero)
	# flush
	sw zero, 4(zero)
	ret
	
read_key_stream:
	lw t0, 2(zero)
	# check for empty stream
	beqz t0, 1f
	# load next key code
	lw a0, 1(zero)
	ret
	1:
	# return 0 if empty stream
	li a0, 0
	ret
	
wait_for_next_key:
	# t0: if stream was open before call
	lw t0, 3(zero)
	# open the stream nethertheless
	li t1, 1
	sw t1, 3(zero) 
	
	push ra
	push t0
	# loop to wait for next key
	0:
	call read_key_stream
	bnez a0, 1f
	j 0b
	1:
	# key code is in a0
	pop t0
	pop ra
	# reset stream state to the original state
	sw t0, 3(zero)
	ret

input:
	# If #1 != 0: saves output string in address #1. else gets more memory from sbrk. 
	# #2: maximum length of str, truncates after that. Writes asciz string until "enter" is pressed or maxium length exceeded
	# Also prints input to str.
	# t0: if stream was open before call
	lw t0, 3(zero)
	# open the stream nethertheless
	li t1, 1
	sw t1, 3(zero)
	# save original stride
	lw t1, 13(zero)
	# set stride to 0
	sw zero, 13(zero)
	# move regs to the stack which we want to keep (ra, t0, t1), and which we want to modify (s..)
	addi sp, sp, -8
	sw ra, 7(sp)
	sw t0, 6(sp)
	sw t1, 5(sp)
	sw s0, 4(sp)
	sw s1, 3(sp)
	sw s2, 2(sp)
	sw s3, 1(sp)
	sw s4, 0(sp)
	# s0: current address of the string
	# s1: end address of string. If string goes to that length: break
	# s2: start address of string
	# s3: persistent temp
	# s4: animation state
	
	# update fdr so that current cursor is at least the second to bottom row -> cursor - fdr <= 10
	lw t0, 5(zero) # cursor row
	lw t1, 9(zero) # FDR
	li t3, 10
	sub t2, t0, t1
	ble t2, t3, 0f
	# set fdr to 10 rows behind cursor
	push a0
	subi a0, t0, 10
	call set_fdr
	pop a0
	0:
	
	mv s1, a1
	bnez a0, 1f
	# a0 == 0 case: get mem from sbrk
	mv a0, a1 # request max length of memory
	call sbrk
	1:
	mv s0, a0 # correct start address, this is the moving pointer
	mv s2, a0 # save start address for return
	# compute correct end address
	add s1, s0, s1 
	dec s1  # have to save a zero word at the end -> useful space is 1 less
	li s4, 0 # init animation reg
	
	# main part: wait for key input, save it in string, and print it
	# TODO: handle backspace
	2:
	beq s0, s1, 4f  # max length: break
	
	# handle animation
	# update animation state
	xori s4, s4, 1
	beq s4, zero, 5f # j to erase animation
    # draw animation
	li a0, 128 # full block
	call print_char
	j 6f
	5:
	# erase animation
	li a0, 32 # blank
	call print_char
	6:
	# animation done
	
	# process key inputs
	call read_key_stream
	beqz a0, 2b # # no key entered: go back to start of loop
	# real key in a0
	# check for 10: break loop
	li s3, 10 # "enter" key code
	beq a0, s3, 4f
	# check for backspace
	li s3, 11 # "backspace" key code
	beq a0, s3, 5f
	# handle scrolling of terminal
	li t0, 9 # up is pressed
	beq a0, t0, 6f
	li t0, 8 # down is pressed
	beq a0, t0, 7f
	# ToDo check for valid input char
	# check if key >= 32 to ensure printable char
	li t0, 32
	ble a0, t0, 8f
	# store in string
	sw a0, 0(s0)
	# print char
	call print_char
	# move cursor one to the right, since stride is 0, have to do it manually. -> No checking of end of line
	lw t0, 6(zero)
	inc s0 # solve mem dependency
	inc t0
	sw t0, 6(zero)
	j 2b
	
	# enter is pressed
	4:
	# erase current animation block
	li a0, 32 # blank
	call print_char
	# add zero word to end of string
	sw zero, 0(s0)
	# cursor to new line
	lw t3, 5(zero)
	sw zero, 6(zero) # solve data dependency by adding the sw here
	inc t3
	sw t3, 5(zero)
	# return start address saved earlier
	mv a0, s2
	lw ra, 7(sp)
	lw t0, 6(sp)
	lw t1, 5(sp)
	lw s0, 4(sp)
	lw s1, 3(sp)
	lw s2, 2(sp)
	lw s3, 1(sp)
	lw s4, 0(sp)
	addi sp, sp, 8
	# reset stream state to the original state
	sw t0, 3(zero)
	# reset stride to original state
	sw t1, 13(zero)
	ret
	
	# backspace is pressed
	5:
	# erase current animation block
	li a0, 32 # blank
	call print_char
	# dec s0, but not lower than s2
	slt a0, s2, s0 # is 1 if s2 < s0, in that case decrement s0
	# dec cursor
	lw t0, 6(zero)
	sub s0, s0, a0 # solve mem dependency
	sub t0, t0, a0 # only update cursor if string is not at start
	sw t0, 6(zero)
	# nothing to do else, animation will update, string will end with 0,
	j 2b
	6:
	li a0, -1
	call set_fdr_rel
	j 2b
	7:
	li a0, 1
	call set_fdr_rel
	j 2b
	8:
	# do nothing, just don't parse the key
	j 2b
	

rand_int:
	dec a0
	blt a0, zero, 1f
	push ra
	push s0 # max value
	mv s0, a0
	call msb  
	li t0, 2 
	sll t0, t0, a0  # modulo max value
	dec t0 # boolean mask of 1s for and
	0: # rejection sampling loop
	lw a0, 17(zero)
	and a0, a0, t0  # ensure positive values, mod of negative number is negative 
	ble a0, s0, 2f
	j 0b # if not, try again
	2:
	pop s0
	pop ra
	ret
	1:
	# input error: a0 == 0
	call raise_exception
	ret
	
rand_word:
	lw a0, 17(zero)
	ret
	
str_to_cstr:
	ret

cstr_to_str:
	ret
	
str_to_int:
	# does not check overflow!
	# a0: address of string
	# returns output in a0, 0 in a1 if everything worked, otherwise 0 in a0, and -1 in a1 if input error
	li t1, 9 # max number to check input
	lw t0, 0(a0) # load first char
	li t2, 0 # output reg
	li t3, 1 # sign of output
	# check if "-" is first char
	li t1, 45 
	bne t0, t1, 4f
	# save negative sign
	li t3, -1
	inc a0 # first sign processed
	lw t0, 0(a0) # load first char again to check for empty string. "-" is not valid.
	4:
	# check for empty string
	beqz t0, 3f # error 
	0:
	lw t0, 0(a0)
	beq t0, zero, 1f
	# process digit
	# decode
	subi t0, t0, 48
	blt t0, zero, 3f # assert t0 >= 0
	bgt t0, t1, 3f # assert t0 <= 9
	muli t2, t2, 10 # shift one digit to the right
	add t2, t2, t0 # new digit added
	inc a0
	j 0b
	1:
	mul t2, t2, t3 # correct sign
	mv a0, t2 # output 
	li a1, 0  # normal processing
	ret
	3:
	# error
	li a0, 0 # give deterministic output
	li a1, -1 # error code
	ret
	
	
int_to_str:
	# Todo: dynamic allocation
	push ra
	push s0
	mv s0, a0  # s0: current int to parse
	li a0, 12 # max 12 characters long, can be refined
	call sbrk
	# a0: current mem location to write char
	addi a0, a0, 10 # go backward
	sw zero, 1(a0) # trailing zero for string end
	# check negative number
	li t0, 1
	bge s0, zero, 1f
	li t0, -1 # negative
	1:
	mul s0, s0, t0 # ensure positive number
	2:
	modi t1, s0, 10 # last digit
	addi t1, t1, 48 # ascii encoding
	sw t1, 0(a0)
	dec a0
	divi s0, s0, 10
	beqz s0, 3f
	j 2b
	3:
	inc a0 # start with first char
	bge t0, zero, 4f
	# add "-" sign
	li t0, 45
	dec a0
	sw t0, 0(a0)
	4:
	# a0 is correct position
	pop s0
	pop ra
	ret
	 
	
	
set_cursor_to_next_line:
	lw t3, 5(zero)
	sw zero, 6(zero) # solve data dependency by adding the sw here
	inc t3
	sw t3, 5(zero)
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
    j 0b

	2:
    addi a2, a4, 1     # L = mid + 1
    j 0b

	1:
    mv a0, a1          # return msb in a0
    ret
	
#msb2:
	#li t0, -1
	#beqz a0, 1f
	#li t0, 0
	#li t1, 2
	#blt a0, t1, 1f
	#li t0, 1
	#li t1, 4
	#blt a0, t1, 1f
	#li t0, 2
	#li t1, 8
	#blt a0, t1, 1f
	#li t0, 3
	#li t1, 16
	#blt a0, t1, 1f
	#li t0, 4
	#li t1, 32
	#blt a0, t1, 1f
	#li t0, 5
	#li t1, 64
	#blt a0, t1, 1f
	#li t0, 1
	#li t1, 4
	#blt a0, t1, 1f
	#1:
	#mv a0, t0
	#ret
	
.data


