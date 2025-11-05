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
# 1058: File System Base address (current hardware: 66560)

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

	# Debugging the file System: TODO: delete this block later
	la a0, debug_path
	li a7, 35 # len_str
	ecall
	
	# request that much RAM (+1 since we want to save the 0x0 at the end of the string too)
	addi a0, a1, 1
	li a7, 2 # sbrk
	ecall
	la t0, debug_path
	# copy string to Memory
	push a0
	1:
	lw t1, 0(t0)
	inc t0
	sw t1, 0(a0)
	inc a0
	beqz t1, 2f # end of string
	j 1b
	2:
	pop a0  # now a0 is the location of the string in RAM
	la a1, debug_name
	li a7, 38 # mkdir
	ecall
	# TODO: right now the file is created in the root directory. that should not happen
	la a0, debug_path_2
	la a1, debug_name_2
	li a7, 37 # create file
	ecall


	li s10, 8743
	halt


# fs_init(a0=fs_base, a1=block_size, a2=num_blocks)
fs_init:
    push ra
    # initialize super block
    li t0, 1128813396 # magic number 'CHST'
    sw t0, 0(a0)      # fs_base + 0: magic number
    li t0, 1
    sw t0, 1(a0)      # fs_base + 1: version, currently 1
    sw a1, 2(a0)      # fs_base + 2: block size
    sw a2, 3(a0)      # fs_base + 3: number of blocks
    li t0, 1
    sw t0, 4(a0)      # fs_base + 4: root directory block index

    # create free map. each word represents a block (0=free, 1=used)
    # initially, block 0 is used for super block, block 1 contains the root directory
    # hence, first two words are set to 1, rest are 0.
    li t1, 1 # first block (super block) used
    sw t1, 5(a0)      # fs_base + 5: free map start
    sw t1, 6(a0)      # fs_base + 6: second block (root dir) used
    # remaining blocks are zero
    # start address: 7(a0)
    addi t0, a0, 7
    # end address: t0 + (num_blocks - 2)
    add t1, t0, a2
    subi t1, t1, 2
    0:
    beq t0, t1, 1f
    sw zero, 0(t0)
    inc t0
    j 0b
    1:
    # super block initialized. Now initialize root directory block

    # structure of directory block: first 250 words are the directory entries. It consists of entries of 5 words each:
    # 0: type of file: (0=unused, 1=file, 2=directory)
    # 1-2: name: empty string for root dir -> 0x0000 0000 in both words
    # 3: start block index: block idx of the first data block of the file/directory. initialized as -1 for unused entries
    # 4: size in words: total file length of raw data in words (not including pointers to the next block)
    # This allows for up to 50 files/directories in any directory. In this simple file system, every directory is always exactly one block in size.
    # That means: the maximum number of files/directories in any directory is 50.
    # After the 250 words of directory entries, we store the parent directory block index (for root dir, it's self referential -> 1)

    # start address of root directory block is fs_base + block_size
    add t0, a0, a1  # t0 = fs_base + block_size
    addi t1, t0, 250 # address of the last directory entries to initialize + 5. Serves as counter variable

    # initialize empty directory entries. Do-while Loop from back to front
    li t3, -1  # start block index for unused file/directory entries
    1:
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
    bne t1, t0, 1b

    # the root directory is a special dir. It is self referenced in its first directory entry. This allows to seek for "/" and get the same output as any other dir
    # -> Define the first directory entry as the root dir itself
    li t3, 2
    sw t3, 0(t0)    # type: directory (2)
    # empty name ( TODO: revisit that)
    sw zero, 1(t0) # name part 1
    sw zero, 2(t0) # name part 2
    # start block index: root dir is at block 1
    li t3, 1
    sw t3, 3(t0)   # start block index
    # size: undefined for directories, already initialized as 0

    # set parent directory index to self (1)
    sw t3, 250(t0)   # parent dir index

    # save start of superblock address in OS RAM
    sw a0, 1058(zero) # fs base address save


    # done, first 2 blocks are initialized, return
    pop ra
    ret



	
.data
	welcome: .asciz "FactOS 1.0.0\n"
	debug_path: .asciz "/"
	debug_name: .asciz "BIN"
	debug_path_2: .asciz "/BIN"
	debug_name_2: .asciz "TESTFILE"

	