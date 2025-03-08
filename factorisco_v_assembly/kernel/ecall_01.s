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
	jal zero, reset
	jal zero, exit
	jal zero, sbrk
	jal zero, raise_exception
	jal zero, get_time
	jal zero, sleep
	jal zero, set_cursor
	jal zero, set_cursor_rel
	jal zero, get_cursor
	jal zero, set_font
	jal zero, get_font
	jal zero, set_fdr
	jal zero, set_fdr_rel
	jal zero, get_fdr
	jal zero, clear_row
	jal zero, cls
	jal zero, print
	jal zero, println
	jal zero, print_char
	jal zero, print_int
	jal zero, cprint
	jal zero, cprint_ln
	jal zero, open_key_stream
	jal zero, close_key_stream
	jal zero, read_key_stream
	jal zero, wait_for_next_key
	jal zero, input
	jal zero, rand_int
	jal zero, rand_word
	jal zero, str_to_cstr
	jal zero, cstr_to_str
	jal zero, str_to_int
	jal zero, int_to_str
	
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
	# bnez 
	# TODO
	ret
	
wait_for_next_key:
	ret

input:
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
	
.data


