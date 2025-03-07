# ECALL implementation
.text
main:
	...
	
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
	
open_key_stream:
	li t0, 1
	sw to, 3(zero)
	ret

close_key_stream:
	sw zero, 3(zero)
	# flush
	sw zero, 4(zero)
	ret
	
read_key_stream:
	lw t0, 2(zero)
	bnez 



.data


