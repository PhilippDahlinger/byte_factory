# ECALL implementation
.text
main:
	nop
	nop
	nop
	push ra
	la t0, jump_table  # in the final version, replace label jump_table la and add with direct immediate of correct offset to jump_table -> saves 3 cycles
	add a7, a7, t0
	jalr ra, 0(a7)
	pop ra
	ret
	
jump_table:
	jal zero, reset
	jal zero, exit
	# jal zero, sbrk
	# jal zero, raise_exception
	
reset:
	li s0, 23
	ret
	
exit:
	li s0, 24
	ret
.data


