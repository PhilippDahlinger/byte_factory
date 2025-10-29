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
	# load a debug string
	la a0, debug_path
	li a7, 35 # fs_abs_seek
	ecall
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
    # initialize super block
    li t0, 1128813396 # magic number 'CHST'
    sw t0, 0(a0)      # fs_base + 0: magic number
    li t0, 1
    sw t0, 1(a0)      # fs_base + 1: version, currently 1
    sw a1, 2(a0)      # fs_base + 2: block size
    sw a2, 3(a0)      # fs_base + 3: number of blocks
    li t0, 1
    sw t0, 4(a0)      # fs_base + 4: root directory block index

    # create free map. each bit represents a block (0=free, 1=used)
    # initially, block 0 is used for super block, block 1 contains the root directory
    # hence, first two bits are set to 1, rest are 0.
    li t1, 3 # first 32 bit word: 00000011
    sw t1, 5(a0)      # fs_base + 5: free map start
    # find out how many words are needed for free map
    addi t2, a2, -1  # num_blocks - 1, we use that to divide by 32 and add 1 to ensure that 1-32 -> 1 free map word, 33-64 -> 2 free map words, etc.
    divi t2, t2, 32 # num_blocks // 32
    # first block of free map already written, need t2 more words (1 extra since we round up)
    addi t3, a0, 6  # pointer to free map area, one word after start
    1:
    beqz t2, 2f
    sw zero, 0(t3) # write 0 to free map word
    dec t2
    inc t3
    j 1b
    2:

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

    # set parent directory index to self (1)
    li t3, 1
    sw t3, 250(t0)   # parent dir index

    # done, first 2 blocks are initialized, return
    pop ra
    ret



	
.data
	welcome: .asciz "FactOS 1.0.0\n"
	debug_path: .asciz "ABC.TXT"

	