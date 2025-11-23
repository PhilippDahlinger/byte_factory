# Interrupt handling
.text
main:
    # entry point of interrupts. We have 4 kinds of interrupts in that order:
    # Invalid Instruction address, Invalid Instruction, Invalid Load/Store Address, and ECALL
    # We are using a vectorized approach and have one line each to handle each interrupt type

    # Handle invalid instruction address
    j invalid_instruction_address_interrupt

    # Handle invalid instruction
    j invalid_instruction_interrupt

    # Handle invalid load/store address
    j invalid_load_store_address_interrupt

    # Handle ECALL: no need to jump since we are at the end of the table
    # check if MPP is user mode (00), if so: load OS sp, else: use existing sp, since we are already in OS mode
    lw t0, 21(zero) # load MPP
	# save stack pointer
	sw sp, 1027(zero)
    bne t0, zero, 1f
	# load OS sp
    lw sp, 1025(zero) 
    1:

    # TODO: adapt to the final ecall limit
	li t1, 50  # last valid ECALL code
	# check for valid ECALL code
	bgt a7, t1, invalid_input
	blt a7, zero, invalid_input

	la t0, jump_table  
	add a7, a7, t0
	# execute ECALL
	jalr ra, 0(a7)

	# add 1 to the previous PC: we want to skip the ECALL which caused the interrupt
	lw t0, 20(zero) # load previous PC
	# restore sp
	lw sp, 1027(zero)
	inc t0
	sw t0, 20(zero) # store back
    # enable interrupts again (they were disabled by the ECALL)
    li t0, 1
    sw t0, 18(zero)
	# go back to the user program
	mret

invalid_instruction_address_interrupt:
	li s10, -1
    # TODO
    nop
    nop
    nop
    nop
    halt
    nop
    nop
    nop
    nop

invalid_instruction_interrupt:
	li s10, -2
    # TODO
    nop
    nop
    nop
    nop

    halt
    nop
    nop
    nop
    nop

invalid_load_store_address_interrupt:
    # TODO
	li s10, -3
    nop
    nop
    nop
    nop
    halt
    nop
    nop
    nop
    nop
	
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
	jal zero, len_str # 35
	jal zero, fs_abs_seek  # 36
	jal zero, fs_touch # 37
	jal zero, fs_mkdir # 38
	jal zero, fs_write_to_file # 39
	jal zero, fs_load_file # 40
	jal zero, fs_del_file # 41
	jal zero, fs_del_dir # 42
	jal zero, fs_file_name_to_str # 43
	jal zero, draw_hex_pixel # 44
	jal zero, set_hex_color # 45
	jal zero, cls_color_display # 46
	jal zero, draw_rgb_pixel # 47
	jal zero, set_rgb_color # 48
	
invalid_input:
	# TODO
	call raise_exception
	
reset:
	# not used
	ret
	
exit:
	# user program ends, go back to os
	# need to reset stack: load OS stack pointer from before the call of user program
	lw sp, 1025(zero)
	# don't have to update sbrk pointer since there are 2 sbrk pointer, one for user, one for os
	
	# reset display 
	li a0, 0 # font
	li a1, 1 # stride
	li a2, 1 # use wrap
	call set_font
	call set_cursor_to_next_line
	
	# don't have to update kernel mode, since we are not calling mret this time -> keep machine mode
	# enable interrupts again (they were disabled by the ECALL)
    li t1, 1
	# load entry point of OS
	lw t0, 1059(zero) # OS entry point stored at address 1059 (end of main loop)
    sw t1, 18(zero)
	jalr zero, 0(t0)
	

sbrk:
    # a0: number of bytes to increase sbrk pointer
    # load correct sbrk pointer depending on MPP
    lw t3, 21(zero) # load MPP
    bne t3, zero, 1f
    # sbrk was called from user mode
	lw t0, 1057(zero) # load old user sbrk pointer
	j 2f
	1:
	# sbrk was called from OS mode
	lw t0, 1024(zero) # load old OS sbrk pointer
	2:
	add t1, t0, a0 # update
	# check for invalid state
	# TODO: update this depending on memory map
	# li t2, 1000
	# blt t1, t2, 1f # if < 1000: memory regime of kernel -> throw exception
	# bge t1, sp, 1f # check if sbrk is in stack regime. sp can grow into sbrk though currently
	# write back updated sbrk pointer, MPP should be still in regs
    bne t3, zero, 2f
    # user mode
	sw t1, 1057(zero)
	j 3f
	2:
	# OS mode
	sw t1, 1024(zero)
	3:
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
	# a0: start address
	# It will ensure that the print is visible: adapts the fdr so that cursor - fdr <= 5 at all times
	# load cursor to adapt fdr if necessary
	lw t3, 5(zero) # cursor
	lw t4, 9(zero) # fdr
	li t5, 5
	sub t6, t3, t4 # cursor - fdr
	blt t6, t5, 3f
	# set fdr so that print is last line
	# that means fdr = cursor - 5
	subi t4, t3, 5
	# set fdr
	sw t4, 9(zero)
	# update display
	sw zero, 12(zero)
	3:
	# t0: char index, starts at a0
	# t1: data reg
	# t2: check for \n = 10
	mv t0, a0
	li t2, 10
	0:
	lw t1, 0(t0)
	inc t0
	beqz t1, 1f
	# check for \n
	beq t1, t2, 2f
	# print char
	sw t1, 7(zero)
	j 0b
	2:
	# \n case, move cursor one row, set col to 0, current cursor already loaded in t3
	# reset cursor col to 0
	sw zero, 6(zero)
	inc t3
	sw t3, 5(zero)
	# check if new cursor row is outside of the display -> update fdr if necessary
	sub t6, t3, t4 # cursor - fdr
	blt t6, t5, 3f
	# set fdr so that print is last line
	# that means fdr = cursor - 5
	subi t4, t3, 5
	# set fdr
	sw t4, 9(zero)
	# update display
	sw zero, 12(zero)
	3:
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
	# TODO: check for FDR if the print is visible (or don't, print_char is a debug thing anyway)
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
	# If a0 != 0: saves output string in address a0. else gets more memory from sbrk. 
	# a1: maximum length of str, truncates after that. Writes asciz string until "enter" is pressed or maxium length exceeded
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
	
	# update fdr so that current cursor is at least the second to bottom row -> cursor - fdr <= 4
	lw t0, 5(zero) # cursor row
	lw t1, 9(zero) # FDR
	li t3, 4
	sub t2, t0, t1
	ble t2, t3, 0f
	# set fdr to 4 rows behind cursor
	push a0
	subi a0, t0, 4
	call set_fdr
	pop a0
	0:
	
	mv s1, a1
	bnez a0, 1f
	# a0 == 0 case: get mem from sbrk
	addi a0, a1, 1 # request max length of memory (+1 to write 0x0 at end of string)
	call sbrk
	1:
	mv s0, a0 # correct start address, this is the moving pointer
	mv s2, a0 # save start address for return
	# compute correct end address
	add s1, s0, s1 
	dec s1  # have to save a zero word at the end -> useful space is 1 less
	li s4, 0 # init animation reg
	
	# main part: wait for key input, save it in string, and print it
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
	blt a0, t0, 8f
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
	li t1, 9 # max digit to check input
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


# len_str(a0: start of str)
# returns a0: start of str (same as input), a1: length of string
len_str:
    mv t7, a0 # save start of str
    li a1, 0  # length counter
    1:
    lw t1, 0(a0)
    inc a0
    beqz t1, 2f # end of string
    # add length 1
    inc a1
    j 1b
    2:
    mv a0, t7 # get original start of str back
    ret

# file system absolute seek (a0: absolute file path)
# returns a0: block index of file start, -1 if not found
#         a1: address for directory entry of file. undefined if not found
fs_abs_seek:
    push ra
    push s0  # block index of file
    push s1  # address for directory entry of file. undefined if not found
    push s2  # last chunk is a dir flag
    push s3  # super block address / fs mount point
    push s4  # block size

    # load super block address
    lw s3, 1058(zero) # super block address
    li s0, 1
    # the root directory is a special dir. It is self referenced in its first directory entry. This allows to seek for "/" and get the same output as any other dir
    # since we have a directory entry.
    # it is the first directory entry -> mount address + 256
    addi s1, s3, 256
    li s2, 1 # last chunk is dir flag
    # load block size
    lw s4, 2(s3) # block size
    # root dir is at block 1
	
	# eliminate last slash of the string
	call len_str
	add t0, a0, a1 # end of str
	lw t1, -1(t0) # load last char
	li t2, 47 # "/"
	bne t1, t2, 1f # start parsing loop if last char is not a slash
	# replace last char with 0x0
	sw zero, -1(t0)
	
    # parsing loop
    1:
    call next_chunk
    # a0: end of current chunk, or -1 if error, or 0 if end of string
    # a1/a2: file name
    beqz a0, 4f  # end of string: Done seeking. prepare outputs and return
    # check if -1: if so return -1 as error
    li t0, -1
    beq a0, t0, 5f # error case
    # if the code reaches this point: the last chunk has to be a dir, otherwise error
    bnez s2, 2f
    # error case
    li a0, -1
    j 5f
    2:
    # save current end of current chunk
    push a0
    # search for file in current dir
    mv a0, s0 # current block index
    mv a3, s3 # fs mount point
    mv a4, s4 # block size
    call find_file_in_dir
    # a0: address of file directory entry, or -1 if not found
    # have to get the end of current chunk back
    pop t7  # store current end of chunk somewhere for later reference
    # check if not found
    li t0, -1
    beq a0, t0, 5f # error case

    # Success: file found. do the update for the next loop
    # update block indices
    lw s0, 3(a0) # load block index of found file
    mv s1, a0  # save address of found file directory entry
    # check if new file is a directory (type == 2)
    lw t0, 0(a0)
    li t1, 2
    beq t0, t1, 2f
    # not a dir
    li s2, 0
    # don't need an else case, since s2 is always set to 1 if code reaches this point
    2:
    # restore end of current chunk
    mv a0, t7
    # next iteration
    j 1b

    4:
    # success case:
    mv a0, s0 # block index
    mv a1, s1 # address of directory entry
    5:
    # return
    pop s4
    pop s3
    pop s2
    pop s1
    pop s0
    pop ra
    ret

# fs_touch: create an empty non-directory file at absolute path
# a0: absolute file path of parent directory
# a1: uncompressed str of new file name
# returns: a0: -1 if error, else address of file entry in parent dir
fs_touch:
    # seek to parent directory
    push ra
    push a1  # save new file name
    call fs_abs_seek
    li a2, 1 # new file type = file
    pop a3  # new file name
    call fs_create_file
    pop ra
    ret


# fs_mkdir: create an empty directory at absolute path
# a0: absolute file path of parent directory
# a1: uncompressed str of new directory name
# returns: a0: -1 if error, else address of file entry in parent dir
fs_mkdir:
    # seek to parent directory
    push ra
    push a1  # save new file name
    call fs_abs_seek
    li a2, 2 # new file type = directory
    pop a3  # new file name
    call fs_create_file
    pop ra
    ret


# fs_write_to_file: 
# a0: uncompressed absolute path to file 
# a1: Start address of data in RAM
# a2: How many words to write
# Returns:
# a0: 0 if successful, -1 if error
fs_write_to_file:
	push s0 # address of current block
	push s1 # link of current block  to next block
	push s2 # RAM start Address
	push s3 # number of words to write
	push s4 # file system mount Address
	push ra
	# TODO: Check MPP. if prev mode was user: check that RAM start and end addresses are in user space, else raise error
	mv s2, a1
	mv s3, a2
	lw s4, 1058(zero)
	call fs_abs_seek
	blt a0, zero, 1f # raise error 
	# a0: block index of file start
	# a1: address of dir entry of that file
	# check if current file type is actually a file (not a dir or empty)
	lw t0, 0(a1)
	li t1, 1
	bne t0, t1, 1f # if not file -> error
	# write new length into dir entry
	sw s3, 4(a1)
	
	# load file start address 
	muli t0, a0, 256 # multiply with block size
	add s0, s4, t0 # address of current block
	lw s1, 255(s0)
	# erase all links of file
	2:
	ble s1, zero, 3f # stop when link is -1. As safety measure: when block is 0 also stop (masterblock will never be linked)
	mv a0, s1
	# compute address of new block
	muli t0, s1, 256
	add t0, s4, t0
	# load next link
	lw s1, 255(t0)
	# free block $a0
	call fs_free_block
	j 2b
	3:
	# now all blocks except the first one are freed
	# set link of first block to -1
	li t0, -1
	sw t0, 255(s0)
	
	# start writing
	4:
	li t0, 255
	ble s3, t0, 7f # less than 255 words to write -> fits in one block
	# save the next 255 words, get a new link, connect and update regs
	# do 15 words at a time for less loops -> less overhead
	5:
	beqz t0, 6f # use t0 as a counter
	lw t1, 0(s2)
	lw t2, 1(s2)
	sw t1, 0(s0)
	sw t2, 1(s0)
	lw t1, 2(s2)
	lw t2, 3(s2)
	sw t1, 2(s0)
	sw t2, 3(s0)
	lw t1, 4(s2)
	lw t2, 5(s2)
	sw t1, 4(s0)
	sw t2, 5(s0)
	lw t1, 6(s2)
	lw t2, 7(s2)
	sw t1, 6(s0)
	sw t2, 7(s0)
	lw t1, 8(s2)
	lw t2, 9(s2)
	sw t1, 8(s0)
	sw t2, 9(s0)
	lw t1, 10(s2)
	lw t2, 11(s2)
	sw t1, 10(s0)
	sw t2, 11(s0)
	lw t1, 12(s2)
	lw t2, 13(s2)
	lw t3, 14(s2)
	sw t1, 12(s0)
	sw t2, 13(s0)
	sw t3, 14(s0)
	
	subi t0, t0, 15
	addi s0, s0, 15
	addi s2, s2, 15
	j 5b
	6:
	# get new link and update regs
	# new remaining length is s3 - 255
	subi s3, s3, 255
	# ask for new block
	call fs_request_new_block
	# check for -1 -> disk full
	blt a0, zero, 1f
	# write that link index to last word of current block
	# since s0 was updated by 255 over the loop -> correct address
	sw a0, 0(s0)
	# compute new address of block in s0
	muli s0, a0, 256
	add s0, s0, s4
	j 4b # continue writing to disk
	7:
	# compute end address
	add t0, s2, s3
	8:
	beq s2, t0, 0f #done
	# lw of RAM, put it into file system storage
	lw t1, 0(s2)
	inc s2
	sw t1, 0(s0)
	inc s0
	j 8b
	0:
	# return 0 for Success
	li a0, 0
	9:
	pop ra
	pop s4
	pop s3
	pop s2
	pop s1
	pop s0
	ret
	
	1:
	# error case
	li a0, -1
	j 9b


# fs_load_file:
# a0: uncompressed absolute path to file to load (has to be a file, not a dir)
# returns:
# a0: RAM address of loaded file (use sbrk of current mode to get the mem). -1 if not successful
# a1: Length of file in RAM
fs_load_file:
	push s0 # address of current block in file system
	push s2 # address of RAM (where to write to)
	push s3 # Length of remaining file to write
	push s4 # FS mount address
	push ra
	# seek to file
	call fs_abs_seek
	# a0: block index of file, a1: address of dir entry
	# check for error
	blt a0, zero, 1f
	# check if current file is not a dir
	lw t0, 0(a1)
	lw s4, 1058(zero) # mount point
	li t1, 1 # correct file type
	bne t0, t1, 1f # if not file -> error
	lw s3, 4(a1) # load file length
	# load address of current block in file system
	muli s0, a0, 256
	add s0, s0, s4 # add offset
	# sbrk for memory
	mv a0, s3
	call sbrk
	# a0: RAM address where to start loading the file
	mv s2, a0
	# start writing
	# push RAM start and file length for later return reference
	push s2
	push s3
	4:
	li t0, 255
	ble s3, t0, 7f # less than 255 words to write -> fits in one block
	# load the next 255 words, get a new link, connect and update regs
	# do 15 words at a time for less loops -> less overhead
	5:
	beqz t0, 6f # use t0 as a counter
	lw t1, 0(s0)
	lw t2, 1(s0)
	sw t1, 0(s2)
	sw t2, 1(s2)
	lw t1, 2(s0)
	lw t2, 3(s0)
	sw t1, 2(s2)
	sw t2, 3(s2)
	lw t1, 4(s0)
	lw t2, 5(s0)
	sw t1, 4(s2)
	sw t2, 5(s2)
	lw t1, 6(s0)
	lw t2, 7(s0)
	sw t1, 6(s2)
	sw t2, 7(s2)
	lw t1, 8(s0)
	lw t2, 9(s0)
	sw t1, 8(s2)
	sw t2, 9(s2)
	lw t1, 10(s0)
	lw t2, 11(s0)
	sw t1, 10(s2)
	sw t2, 11(s2)
	lw t1, 12(s0)
	lw t2, 13(s0)
	lw t3, 14(s0)
	sw t1, 12(s2)
	sw t2, 13(s2)
	sw t3, 14(s2)
	
	subi t0, t0, 15
	addi s0, s0, 15
	addi s2, s2, 15
	j 5b
	6:
	# get new link and update regs
	# new remaining length is s3 - 255
	subi s3, s3, 255
	
	# load link of current block
	# since s0 was updated by 255 over the loop -> correct address
	lw a0, 0(s0)
	# compute new address of block in s0
	muli s0, a0, 256
	add s0, s0, s4
	j 4b # continue loading from disk
	7:
	# compute end address
	add t0, s0, s3
	8:
	beq s0, t0, 0f #done
	# lw of file, put it into RAM
	lw t1, 0(s0)
	inc s0
	sw t1, 0(s2)
	inc s2
	j 8b
	0:
	# get return RAM address and length
	pop a1
	pop a0
	9:
	# restore stack
	pop ra
	pop s4
	pop s3
	pop s2
	pop s0
	ret
	1:
	# error Case
	li a0, -1
	j 9b
	
	
# fs_del_file
# a0: abs path to file
# return a0: 0 if success, -1 if error
fs_del_file:
	push ra
	call fs_abs_seek
	# a0: block index of file, a1: dir entry
	blt a0, zero, 1f # if -1: error ret
	# check if type is actually a file
	lw t0, 0(a1)
	li t1, 1 # file type
	bne t0, t1, 1f
	# a1: dir entry of file to delete
	call internal_del_file
	li a0, 0 # Success
	0:
	pop ra
	ret
	# error
	1:
	li a0, -1
	j 0b


# fs_del_dir
fs_del_dir:
# a0: abs path to empty (!) folder
# return a0: 0 if success, -1 if error
	push ra
	call fs_abs_seek
	# a0: block index of file, a1: dir entry
	blt a0, zero, 1f # if -1: error ret
	# check if type is actually a dir
	lw t0, 0(a1)
	li t1, 2 # dir type
	bne t0, t1, 1f
	# check if directory is empty
	# load address of dir
	lw t0, 1058(zero)
	muli a0, a0, 256
	add a0, a0, t0 # address of dir
	addi t0, a0, 250 # last file entry 
	2:
	beq a0, t0, 3f
	lw t1, 0(a0) # load type of file
	addi a0, a0, 5 # go to next file
	bnez t1, 1f # error if not empty file
	j 2b
	3:
	# dir is empty, can safely delete
	# a1: dir entry of file to delete
	call internal_del_file
	li a0, 0 # Success
	0:
	pop ra
	ret
	# error
	1:
	li a0, -1
	j 0b
	
# fs_file_name_to_str
# a0/a1: file name string
# returns: a0: pointer to uncompressed string (created using sbrk). Always request 9 words for that (easier to delete once done with it)
fs_file_name_to_str:
	push a0
	push a1
	push ra
	li a0, 9
	call sbrk # request 9 new words
	mv t6, a0 # store start Address
	mv t5, a0 # ref for start of string
	pop ra
	pop a1
	pop a0
	
	# load first byte
	srai t0, a0, 24
	andi t0, t0, 255
	beqz t0, 0f
	# write byte
	sw t0, 0(t6)
	inc t6
	
	# load second byte
	srai t0, a0, 16
	andi t0, t0, 255
	beqz t0, 0f
	# write byte
	sw t0, 0(t6)
	inc t6
	
	# load 3. byte
	srai t0, a0, 8
	andi t0, t0, 255
	beqz t0, 0f
	# write byte
	sw t0, 0(t6)
	inc t6
	
	# load 4. byte
	# already correctly shifted
	andi t0, a0, 255
	beqz t0, 0f
	# write byte
	sw t0, 0(t6)
	inc t6
	
	# load 5. byte
	srai t0, a1, 24
	andi t0, t0, 255
	beqz t0, 0f
	# write byte
	sw t0, 0(t6)
	inc t6
	
	# load 6. byte
	srai t0, a1, 16
	andi t0, t0, 255
	beqz t0, 0f
	# write byte
	sw t0, 0(t6)
	inc t6
	
	# load 7. byte
	srai t0, a1, 8
	andi t0, t0, 255
	beqz t0, 0f
	# write byte
	sw t0, 0(t6)
	inc t6
	
	# load 8. byte
	# already correctly shifted
	andi t0, a1, 255
	beqz t0, 0f
	# write byte
	sw t0, 0(t6)
	inc t6
	
	# if code reaches this: all 8 chars are added
	0:
	# add zero byte to current cursor
	sw zero, 0(t6)
	mv a0, t5
	ret

# draw_hex_pixel
# a0: x coord 
# a1: y coord
# returns nothing, to optimize speed
draw_hex_pixel:
	sw a0, 22(zero)
	sw a1, 23(zero)
	sw zero, 29(zero) # draw based on hex color
	ret
	
# a0: hex color code
set_hex_color:
	sw a0, 27(zero)
	ret
	
cls_color_display:
	sw zero, 30(zero)
	ret
	
draw_rgb_pixel:
	sw a0, 22(zero)
	sw a1, 23(zero)
	sw zero, 28(zero) # draw based on rgb color
	ret
	
set_rgb_color:
	sw a0, 24(zero)
	sw a1, 25(zero)
	sw a2, 26(zero)
	ret

# Helper functions for file system operations

# internal_del_file
# a1: address of dir entry of file to delete
internal_del_file:
	push s0 # dir entry address
	push s1 # next block idx
	push s2 # fs mount point
	push ra
	lw s2, 1058(zero) # mount point of fs
	lw s1, 3(a1) # load first block index in s1
	mv s0, a1
	1:
	ble s1, zero, 2f # if last block is reached: stop
	# go to block in s1
	muli t0, s1, 256
	add t0, t0, s2 # address of next block
	mv a0, s1
	# load link
	lw s1, 255(t0)
	# free block
	call fs_free_block
	j 1b
	2:
	# delete dir entry of that file
	sw zero, 0(s0) # type is 0 = unused
	li t0, -1
	sw t0, 3(s0)  # first block is -1 = non existent
	sw zero, 4(s0) # size is 0
	pop ra
	pop s2
	pop s1
	pop s0
	ret
#

# fs_create_file
# args: a0: block index of parent dir, a1: file entry of this parent dir (in parent of parent dir),
# a2: type of new file (1 = file, 2 = dir), a3: uncompressed str of new file name
# returns: a0: -1 if error, else address of file entry in parent dir
fs_create_file:
    # check for error
    blt a0, zero, 1f
    # a0: block index of parent dir, a1: file entry of this parent dir (in parent of parent dir)
    # check if a0 is actually a dir
    lw t0, 0(a1)
    li t1, 2
    bne t0, t1, 1f # error: not a dir
    # check if file type is either 1 or 2
    ble a2, zero, 1f # error: invalid type
    bgt a2, t1, 1f # error: invalid type
	push ra
	push a0 # block index of parent dir
	push a2 # type
	
	# get filename string
    mv a0, a3 # load uncompressed file name
    # compute length
    call len_str  # -> a0 is unchanged, length of str is in a1
    # check if 0 < length <= 8
    ble a1, zero, 2f # error: length 0
    li t0, 8
    bgt a1, t0, 2f # error: length > 8
    # get the actual filename string
    call str_to_file_name
    # a1/a2: compressed file name
	push a1
	push a2
	
	# check if the file name already exists in parent dir
	# load fs mount address
    lw a3, 1058(zero) # fs mount address
	lw a0, 3(sp) # block index of parent dir
	lw a4, 2(a3) # block size
	call find_file_in_dir
	# if a0 is now not -1: the file already exist -> throw error
	bge a0, zero, 3f  # >= 0: file found
	
    # allocate a new file -> ask for a new block
    call fs_request_new_block
    blt a0, zero, 3f # error: could not allocate new block
    # a0: block index of new block
	pop a2
	pop a1  # restore file name

    # find address of parent dir
    # load fs mount address
    lw t0, 1058(zero) # fs mount address
    pop t6 # type of new file (mem dep resolve)
    # load block size
    lw t1, 2(t0) # block size
    pop t5 # block index of parent dir (mem dep resolve)
    mul t1, t1, t5 # block size * block index of parent dir
    # already precompute the address for the new file (only needed if a dir is created, but it makes sense to do it now since all the offsets are loaded)
    mul t4, t1, a0 # block size * block index of new file
    add t1, t0, t1 # address of parent dir block
    add t4, t0, t4 # address of new file block

    # find empty entry in parent dir
    addi t0, t1, 250 # max 50 * 5 = 250 entries per dir (one entry is 5 words)
    5:
    beq t0, t1, 4f # error if no empty entry found
    lw t2, 0(t1)
    addi t1, t1, 5 # count up (solve mem dep)
    beqz t2, 6f # empty entry found
    j 5b
    6:
    subi t1, t1, 5 # undo one counting (faster like this for mem dep resolve)

    # everything ready to create the file entry in the parent dir
    sw t6, 0(t1)    # type of new file
    sw a1, 1(t1)    # first part of name
    sw a2, 2(t1)    # second part of name
    sw a0, 3(t1)    # block index of new file
    sw zero, 4(t1)  # size of new file = 0

    push t1 # save address of new file entry for later cleanup

    # create file entry table if new file is a directory
    li t0, 2
    bne t6, t0, 7f
    # new file is a directory, address of new file block is in t4
    addi t1, t4, 250 # address of the last directory entries to initialize + 5. Serves as counter variable
    # initialize empty directory entries. Do-while Loop from back to front
    li t3, -1  # start block index for unused file/directory entries
    8:
    subi t1, t1, 5
    # type: unused
    sw zero, 0(t1)
    # name: empty string
    sw zero, 1(t1)
    sw zero, 2(t1)
    # start block index: not occupied, so -1
    sw t3, 3(t1)
    # size: 0
    sw zero, 4(t1)
    bne t1, t4, 8b
	
	# set address 250: the parent dir block (stored in t5). used maybe at some point for cd command
	sw t5, 250(t4)
    # done creating new dir
    7:
    # cleanup and return: no error
    pop a0  # file entry address of new file
    pop ra
    ret

    3:
    addi sp, sp, 2 # clean up stack
    2:
    addi sp, sp, 2  # clean up stack
    4:
    pop ra
    1:
    # error
    li a0, -1
    ret


# Ask for a new block from the FS
# returns: a0: block idx of new block, or -1 if error (e.g. full disk)
fs_request_new_block:
    # load fs mount address
    lw t0, 1058(zero) # fs boot address
    # find out how many blocks there are
    lw t1, 3(t0) # total blocks
    addi t0, t0, 5 # address of the first possible free word in the freemap
    mv t7, t0  # store reference of first address to find the correct block
    add t2, t0, t1 # end index of possible free block
    # loop and find next free block
    # do 2 blocks at a time for faster processing
    1:
    bgt t0, t2, 2f
    lw t3, 0(t0)
    lw t4, 1(t0)
    beqz t3, 3f  # 0 = free block
    beqz t4, 4f
    addi t0, t0, 2
    j 1b
    2:
    # error case
    li a0, -1
    ret
    4:
    # add 1 to t0 since we have an offset of 1 in the loop
    inc t0
    3:
    # set this block to 1
    li t3, 1
    sw t3, 0(t0)
    sub a0, t0, t7  # current address - start address = block index
	# Go into the data of this new block and set its link to -1
	# Newly requested blocks never have a link, and this initializes the link correctly
	lw t0, 1058(zero) # fs boot address
	addi t2, a0, 1  # go to end of that file
	lw t1, 2(t0)
	mul t1, t1, t2 
	add t1, t1, t0
	li t3, -1
	sw t3, -1(t1)  # -1 as last word of the new allocated block
	
    ret


# fs_free_block: given block idx in a0, mark it as free in the free table. do not need to delete any data in the block
# returns: block idx if successful, -1 if block outside of range
fs_free_block:
    # load fs mount address
    lw t0, 1058(zero) # fs boot address
    # find out how many blocks there are
    lw t1, 3(t0) # total blocks
    bge a0, t1, 1f # error: block idx out of range
    blt a0, zero, 1f # error: block idx out of range
    add t0, t0, a0 # add block index
    # set block to 0
    sw zero, 5(t0) # free map starts 5 words after fs boot address
    ret
    1:
    # error:
    li a0, -1
    ret


# Seek helpers:

# find file in current dir (a0: current block index, a1/a2: file name, a3: fs mount point, a4: block size)
# returns: address of file directory entry, or -1 if not found
# Assumes that block a0 is actually a dir, and not a raw file!
find_file_in_dir:
    # get address of current dir block
    # mount point + block size * block index
    mul t0, a4, a0
    add t0, t0, a3
    li t2, 250 # max 50 * 5 = 250 entries per dir (one entry is 5 words)
    add t2, t0, t2 # end address of dir block
    1:	
    beq t0, t2, 3f # end of loop: file not found
    # check if entry is empty, if so: continue
    lw t3, 0(t0)
    addi t0, t0, 5 # solve mem dependency
    beqz t3, 1b
    # load entry name, since we already added 5 -> have to subtract 5 (want 1/2 of old t0 -> -4, -3 of new one)
    lw t3, -4(t0)
    lw t4,-3(t0)
    # compare with a1/a2, mismatch: continue
    bne a1, t3, 1b
    bne a2, t4, 1b


    # if code reaches this, there was a match
    # return address of entry: t0 - 5 since we added 5 earlier in the last loop execution
    subi a0, t0, 5
    ret

    3:
    # ERROR Case
    li a0, -1
    ret

# next_chunk (a0: start pointer address of string)
# returns: a0: end pointer address of current chunk, or 0 if end of string, or -1 if error
#          a1/a2: file name in current chunk, already converted to file name format
next_chunk:
    # check valid first char
    lw t0, 0(a0)
    li t2, 47 # "/"
    # check if t0 is 0x0
    bnez t0, 1f
    li a0, 0
    ret
    1:
    # check if first char is "/"
    beq t0, t2, 1f
    li a0, -1
    ret

    # Find out length of name
    1:
    addi t0, a0, 1
    li a1, 0  # length counter
    1:
    lw t1, 0(t0)
    inc t0
    beqz t1, 2f # end of string
    beq t1, t2, 2f # found "/"
    # add length 1
    inc a1
    j 1b
    2:
    # check if length == 0 or length > 8: error
    li t3, 8
    beq a1, zero, 4f
    bgt a1, t3, 4f
    3:
    # save current pos of cursor
    subi t0, t0, 1
    push t0

    # call str_to_file_name
    inc a0  # move to first char of name
    push ra
    call str_to_file_name
    pop ra
    pop a0 # return end of current chunk
    ret
	
	4:
	# error
	li a0, -1
	ret


# str_to_file_name (a0: start pointer address of string, a1: length of string)
# returns: a1/a2: compressed file name
str_to_file_name:
    # it is already checked that a1 <= 8
	# t0 = t1 = 0x00000000
	# counter = 0
	# if length >= 4:
	# 	push 4x data value into t0 (that means: shl by a byte, or the current byte)
	#	push length - 4 x data value into t1, push 8 - length x 0x00 into t1
	# else:
	#	push length x data value into t0, push 4 - length x 0x00 into t0
	# mv a1, t0; mv a2, t1
	# return a1, a2

	li t0, 0
	li t1, 0
	li t3, 4

	blt a1, t3, 1f
	# length >= 4

	# fill in the first 4 bytes
	lw t4, 0(a0)
	lw t5, 1(a0)
	# byte mask
	andi t4, t4, 255
	andi t5, t5, 255
	# push into t0
	slli t0, t0, 8
	or t0, t0, t4
	slli t0, t0, 8
	or t0, t0, t5
	# do the same again
	lw t4, 2(a0)
	lw t5, 3(a0)
	# byte mask
	andi t4, t4, 255
	andi t5, t5, 255
	# push into t0
	slli t0, t0, 8
	or t0, t0, t4
	slli t0, t0, 8
	or t0, t0, t5

    # fill the remaining ones
    li t2, 4  # counter
    3:
    beq a1, t2, 2f
      add t5, a0, t2 # address of next byte
      lw t4, 0(t5)
      # increment counter here to solve mem dependency
      inc t2
      andi t4, t4, 255
      slli t1, t1, 8
      or t1, t1, t4
      j 3b
    2:
    # shift bytes to the left to fill up to 8 bytes
    # num remaining bytes is 8 - length
    li t2, 8
    sub t2, t2, a1
    muli t2, t2, 8
    sll t1, t1, t2
    j 4f

	1:
    # length < 4
    li t2, 0  # counter
    3:
    beq a1, t2, 2f
      add t5, a0, t2 # address of next byte
      lw t4, 0(t5)
      # increment counter here to solve mem dependency
      inc t2
      andi t4, t4, 255
      slli t0, t0, 8
      or t0, t0, t4
      j 3b
    2:
    # shift bytes to the left to fill up to 4 bytes
    # num remaining bytes is 4 - length
    li t2, 4
    sub t2, t2, a1
    muli t2, t2, 8
    sll t0, t0, t2
    4:
    mv a1, t0
    mv a2, t1
    ret

# end seek helpers

.data


