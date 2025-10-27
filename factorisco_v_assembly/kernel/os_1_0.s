# Linux-style OS with file system support

# Memory map:
# 17: MODE
# 18: MIE
# 20: MEPC
# 21: MPP
# 0-1023: Hardware I/O
# 1024-1099: direct mapped OS reserved: sbrk pointer starts at 1100

# 1024: OS Sbrk pointer
# 1025: OS Stack pointer save if user program running
# 1026-1056: Shadow register save area
# 1057: User Sbrk pointer

# 1100-2999: Heap area for sbrk for OS
# 2999-4999: Stack area for OS
# 5000-17407: User program area

.text
boot:
    # enable interrupts
	li t0, 1
	sw t0, 18(zero)
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

	li sp, 4999  # init OS sp
	li t0, 1100 # initial value of sbrk pointer
	sw t0, 1024(zero) # sbrk pointer init

	# init file system (later on, implement that as an installation step. basically have an OS installer on a ROM)
	li a0, 66560 # fs base address
	li a1, 256      # block size
	li a2, 64       # number of blocks
	call fs_init
	nop
	nop
	nop
	nop
	halt
	nop
	nop
	nop


# fs_init(a0=fs_base, a1=block_size, a2=num_blocks)
fs_init:
    push ra
    # debug example
    li a7, 19
    ecall # print
    pop ra
    ret



	
.data
	welcome: .asciz "FactOS 1.0.0\n"

	