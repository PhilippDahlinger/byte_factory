# ECALL implementation
.text
main:
	push ra
	li t1, 34  # last valid ECALL code
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
	# TODO
	call raise_exception
	
	
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
	
reset:
	li s0, 23
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
	subi a0, a0, 5
	call set_fdr # make print statement in the middle of the screen to see output from program clearly
	
	
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


