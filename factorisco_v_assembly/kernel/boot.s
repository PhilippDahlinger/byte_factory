# BOOT
.text
main:
	# reset all regs
	li x1, 0
	li x2, 0
	li x3, 0
	li x4, 0
	li x5, 0
	li x6, 0
	li x7, 0
	li x8, 0
	li x9, 0
	li x10, 0
	li x11, 0
	li x12, 0
	li x13, 0
	li x14, 0
	li x15, 0
	li x16, 0
	li x17, 0
	li x18, 0
	li x19, 0
	li x20, 0
	li x21, 0
	li x22, 0
	li x23, 0
	li x24, 0
	li x25, 0
	li x26, 0
	li x27, 0
	li x28, 0
	li x29, 0
	li x30, 0
	li x31, 0

	li sp, 33000  # init sp
	li t0, 1000 # initial value of sbrk pointer
	sw t0, 256(zero) # address 256 = sbrk pointer
	
	# reset display
	li a7, 15 
	ecall # cls
	li a7, 6
	li a0, 0
	li a1, 0
	ecall # set cursor to 0,0
	# set font to default: no wrap, and stride is 1
	li a7, 9
	li a0, 0 # font
	li a1, 1 # stride
	li a2, 0 # no wrap
	ecall
	
	# reset keyboard
	# close and flush key stream
	li a7, 23 
	ecall # close_key_stream
	
	# print welcome string
	la a0, welcome
	li a7, 17
	ecall
	
	# hardcoded entry point of OS program in kernel ROM #2
	li t0, 139776
	jalr zero, 0(t0)
	nop
	nop

.data
	welcome: .asciz "Welcome to FactOS 0.1.0!\n"
