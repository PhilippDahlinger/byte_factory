# ECALL implementation
.text
main:
	push ra
	li t1, 32  # last valid ECALL code
	# check for valid ECALL code
	bgt a7, t1, invalid_input
	blt a7, zero, invalid_input
	la t0, jump_table  # in the final version, replace label jump_table la and add with direct immediate of correct offset to jump_table -> saves 3 cycles
	add a7, a7, t0
	# execute ECALL
	jalr ra, 0(a7)
	# remove kernel access. Since ECALL adds +1 to the kernel address in hardware, decrease it by 1. -> Same access as before the ecall instruction
	lw t0, 15(zero)
	dec t0
	sw t0, 15(zero)
	pop ra
	ret
	
invalid_input:
	
	
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
	
reset:
	li s0, 23
	ret
	
exit:
	# user program ends, go back to os
	# need to reset stack, set ra correctly on the stack, increment kernel mode to be in kernel mode after ecall decrements it again
	# in current single program mode: terminate cpu
	halt
	nop
	nop
	nop
	nop
	nop
	nop
	
	
	lw t0, 15(zero)
	inc t0
	sw t0, 15(zero)
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
	ret

get_time:
	ret

sleep:
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
	push ra
	push t0
	push s0
	push s1
	push s2
	# s0: current address of the string
	# s1: end address of string. If string goes to that length: break
	# s2: start address of string
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
	
	# main part: wait for key input, save it in string, and print it
	# TODO: handle backspace
	li t2, 10 # "enter" key code
	2:
	beq s0, s1, 4f  # max length: break
	call read_key_stream
	beqz a0, 3f 
	# real key in a0
	# check for 10: break loop
	beq a0, t2, 4f
	# store in string
	sw a0, 0(s0)
	inc s0
	# print char
	call print_char
	3:
	j 2b
	4:
	# add zero word to end of string
	sw zero, 0(s0)
	# cursor to new line
	lw t3, 5(zero)
	sw zero, 6(zero) # solve data dependency by adding the sw here
	inc t3
	sw t3, 5(zero)
	
	# return start address saved earlier
	mv a0, s2
	pop s2
	pop s1
	pop s0
	pop t0
	pop ra
	# reset stream state to the original state
	sw t0, 3(zero)
	ret

rand_int:
	ret
	
rand_word:
	ret
	
str_to_cstr:
	ret

cstr_to_str:
	ret
	
str_to_int:
	ret
	
int_to_str:
	ret
	
set_cursor_to_next_line:
	lw t3, 5(zero)
	sw zero, 6(zero) # solve data dependency by adding the sw here
	inc t3
	sw t3, 5(zero)
	ret
	
.data


