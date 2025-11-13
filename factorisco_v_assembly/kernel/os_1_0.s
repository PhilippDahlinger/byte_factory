# Linux-style OS with file system support

# Memory map:
# 17: MODE
# 18: MIE
# 20: MEPC
# 21: MPP
# 0-1023: Hardware I/O
# 1024-1099: direct mapped OS reserved: sbrk pointer starts at 1100

# 1024: OS sbrk pointer
# 1025: OS Stack pointer save if user program running
# 1026-1056: Shadow register save area
# 1057: User sbrk pointer
# 1058: File System Base address (current hardware: 66560)
# 1059: OS Main Loop start address
# 1060: OS sbrk start of main loop safe

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
	la t0, end_main_loop
	sw t0, 1059(zero) # main_loop end address. Needed for returning from user program
	
	# reset display
	li a7, 15
	ecall # cls
	li a0, 0
	li a1, 0
	li a7, 6
	ecall # set cursor to 0,0
	# set font to default: no wrap, and stride is 1
	li a7, 9
	li a0, 0 # font
	li a1, 1 # stride
	li a2, 1 # allow wrap
	ecall
	# set fdr to 0
	li a0, 0
	li a7, 11
	ecall

	# init file system (later on, implement that as an installation step. basically have an OS installer on a ROM)
	li a0, 66560 # fs base address
	li a1, 256      # block size
	li a2, 64       # number of blocks
	call fs_init
	
	# start the OS
	la a0, welcome
	li a7, 17
	ecall
	call main_loop
	
	
main_loop:
# Save current sbrk pointer
# Wait for command using "input" (request for 40 chars, make sure to wrap input)
# Set cursor to new line
# Parse string by space -> get substrings <command> <arg1> <arg2> ...
    # Pointers to these strings are saved in an array at a fixed location
# Parse <command> string: compute "hash":
    # currenthash *= 10, add ASCII of string until string ends
# Compare with fixed array of valid command hashes
    # If collision: check correct number of arguments, load string pointers to a0–a1, call command subroutine
    # If no collision found: output "unknown command"
# Clean up sbrk pointer to position at start of main loop
	# save sbrk pointer at start of loop. Returns to that at end of loop -> no memory leaks
	lw t0, 1024(zero)
	la a0, prompt # mem dep solve
	sw t0, 1060(zero)
	# save current stack pointer to mem. will be loaded when user program ends
	sw sp, 1025(zero)
	# print the command prompt 
	li a7, 16
	ecall
	# request an input
	li a0, 0 # use sbrk
	li a1, 40 # max 40 chars
	li a7, 26
	ecall
	mv s0, a0 # s0: input string
	
	# parse input string
	# request array to store the pointers to the split string
	li a0, 20 # max 20 words (since 40 is the string long)
	li a7, 2 # sbrk
	ecall
	mv s1, a0 # s1: base address for token array
	li s2, 0 # s2: number of tokens
	mv t0, s0 # t0: current cursor to parse string
	li t1, 32 # t1: " " 
	
	# move over all empty spaces
	0:
	lw t2, 0(t0)  # t2: current char to parse
	bne t1, t2, 1f
	# t2 is space -> increment counter
	inc t0
	j 0b
	1:
	# actual loop for parsing
	# if t2 is 0x0: break parsing Loop
	beqz t2, 2f
	# save current start of string in the array
	add t3, s1, s2 # address of current token to save
	sw t0, 0(t3) # save current cursor pos = start of string in array
	# inc length
	inc s2
	# inner loop to go over the word
	3:
	beq t2, t1, 4f # found " "
	beqz t2, 2f # end of string: done parsing
	lw t2, 1(t0) # load next char, do it like this to solve a mem dep
	inc t0
	j 3b
	
	4: # found a " "
	# replace " " with 0x0 to mark the end of this string
	sw zero, 0(t0)
	inc t0
	j 0b # continue with the next token
	
	# Done parsing
	2:
	# for the command (first argument) compute the hash
	lw a0, 0(s1)
	call hash64_word_38
	# find the hash in the list
	la t0, cmd_hashes
	# end of array
	addi t2, t0, 9
	5:
	beq t0, t2, invalid_cmd
	lw t1, 0(t0)
	inc t0
	bne a0, t1, 5b # branch if incorrect hash
	dec t0 # correct address is one less since it is inc 1 before check
	la t1, cmd_hashes
	sub a7, t0, t1 # offset in the array
	la t0, jump_table  
	add a7, a7, t0
	# execute CMD
	jalr ra, 0(a7)
	# command is executed
	
	end_main_loop:
	# restore sbrk
	lw t0, 1060(zero)
	sw t0, 1024(zero)
	j main_loop
	
	invalid_cmd:
	# write that command is unknown
	la a0, unknown_cmd
	li a7, 17
	ecall # println
	j end_main_loop # cleanup sbrk
	

#----------------------------------------
# Command implementations	
jump_table:
	jal zero, cmd_ls #0
	jal zero, cmd_mkdir #1
	jal zero, cmd_touch #2
	jal zero, cmd_cp #3
	jal zero, cmd_cprom #4
	jal zero, cmd_run #5
	jal zero, cmd_runrom #6
	jal zero, cmd_mv #7
	jal zero, cmd_rm #8

cmd_ls:
	push ra
	# check that total number of args is 2
	li t0, 2
	beq s2, t0, 0f
	la a0, error_invalid_args
	li a7, 17
	ecall
	pop ra
	ret
	0:
	# execute command
	# load arg
	lw a0, 1(s1)
	li a7, 36
	ecall # abs_seek
	# check if cmd was succesful
	blt a0, zero, 1f
	# check file type
	lw t0, 0(a1)
	li t1, 2
	beq t0, t1, 2f
	# invalid type of file (not a dir)
	j 1f
	2: # DIR type
	push s0
	push s1
	# load file address
	lw t0, 1058(zero) # superblock address
	muli a0, a0, 256 # multiply with block size
	add s0, a0, t0 # correct address in a0
	# end of dir
	addi s1, s0, 250
	# loop over all possible file names
	3:
	beq s0, s1, 4f
	# load type
	lw t0, 0(s0)
	addi s0, s0, 5
	beqz t0, 3b # if unused entry: go next
	# write "DIR" in front of the name if file is a dir
	li t1, 2
	bne t0, t1, 5f
	# write DIR
	la a0, dir_string
	li a7, 16
	ecall # print without new line
	5:
	# load filename, s0 increment, so subtract 5
	lw a0, -4(s0)
	lw a1, -3(s0)
	li a7, 43
	ecall
	# got new string in a0 -> print that with new line
	li a7, 17
	ecall # println
	# dont worry about the memory, os sbrk will be resetted after this command
	j 3b
	4:
	# return
	pop s1
	pop s0
	pop ra
	ret
	1:
	# error executing RM
	la a0, error_execution
	li a7, 17
	ecall
	pop ra
	ret
	
	
	
	
cmd_mkdir:
	push ra
	# check that total number of args is 3
	li t0, 3
	beq s2, t0, 0f
	la a0, error_invalid_args
	li a7, 17
	ecall
	pop ra
	ret
	0:
	# execute command
	# load args 
	lw a0, 1(s1)
	lw a1, 2(s1)
	li a7, 38
	ecall # mkdir
	# check if cmd was succesful
	bge a0, zero, 1f
	# error executing MKDIR
	la a0, error_execution
	li a7, 17
	ecall
	pop ra
	ret
	1:
	# return
	pop ra
	ret

cmd_touch:
	push ra
	# check that total number of args is 3
	li t0, 3
	beq s2, t0, 0f
	la a0, error_invalid_args
	li a7, 17
	ecall
	pop ra
	ret
	0:
	# execute command
	# load args 
	lw a0, 1(s1)
	lw a1, 2(s1)
	li a7, 37
	ecall # touch
	# check if cmd was succesful
	bge a0, zero, 1f
	# error executing TOUCH
	la a0, error_execution
	li a7, 17
	ecall
	pop ra
	ret
	1:
	# return
	pop ra
	ret

cmd_cp:
	ret

cmd_cprom:
	push ra
	# check that total number of args is 3
	li t0, 3
	beq s2, t0, 0f
	la a0, error_invalid_args
	li a7, 17
	ecall
	pop ra
	ret
	0:
	# execute command
	# load args 
	lw a0, 1(s1)
	# convert str to int
	li a7, 31
	ecall # str to int
	# check if a1 is -1
	blt a1, zero, 2f
	li t0, 1
	blt a0, zero, 2f
	bgt a0, t0, 2f
	# 0 or 1 in a0
	# load start of ROM
	la t0, rom_start_addresses
	add t0, t0, a0
	lw a1, 0(t0)
	inc a1 # start of file is one word later
	lw a2, -1(a1) # since in first word is the length of the program
	lw a0, 2(s1)
	li a7, 39
	ecall # fs_write_to_file
	blt a0, zero, 2f # check for errors	
	1:
	# return
	pop ra
	ret
	2:
	# error
	la a0, error_execution
	li a7, 17
	ecall
	pop ra
	ret
	

cmd_run:
	ret

cmd_runrom:
	push ra
	# check that total number of args is 2 ( one for the command, one for the rom number)
	li t0, 2
	beq s2, t0, 0f
	la a0, error_invalid_args
	li a7, 17
	ecall
	pop ra
	ret
	0:
	# check that input is either 0 or 1
	lw a0, 1(s1)
	# convert str to int
	li a7, 31
	ecall # str to int
	# check if a1 is -1
	blt a1, zero, 2f
	li t0, 1
	blt a0, zero, 2f
	bgt a0, t0, 2f
	# execute Command
	push a0
	# reset user sbrk
	li t0, 5000
	sw t0, 1057(zero)
	li a0, 10
	li a7, 18
	ecall # print new line
	li a7, 23
	ecall # close key stream
	pop a0
	# set user stack pointer
	li sp, 17400
	# set mode to user
	sw zero, 17(zero)
	# load correct address
	la t0, rom_start_addresses
	add t0, t0, a0
	lw a2, 0(t0) # load start address
	# the actual start address is shifted by 1, since the first word contains the number of words stored on this ROM
	inc a2
	# execute user program
	jr a2
	2:
	# error
	la a0, error_execution
	li a7, 17
	ecall
	pop ra
	ret
	
	
	
cmd_mv:
	ret
	
cmd_rm:
	push ra
	# check that total number of args is 2
	li t0, 2
	beq s2, t0, 0f
	la a0, error_invalid_args
	li a7, 17
	ecall
	pop ra
	ret
	0:
	# execute command
	# load arg
	lw a0, 1(s1)
	li a7, 36
	ecall # abs_seek
	# check if cmd was succesful
	blt a0, zero, 1f
	# check file type
	lw t0, 0(a1)
	li t1, 1
	beq t0, t1, 2f
	li t1, 2
	beq t0, t1, 3f
	# invalid type of file
	j 1f
	2: # FILE type
	lw a0, 1(s1)
	li a7, 41
	ecall # del file
	blt a0, zero, 1f
	# correct execution
	j 4f
	3: # DIR type
	lw a0, 1(s1)
	li a7, 42
	ecall # del folder
	blt a0, zero, 1f
	# don't need to jump, already at correct line
	4:
	# return
	pop ra
	ret
	1:
	# error executing RM
	la a0, error_execution
	li a7, 17
	ecall
	pop ra
	ret
	
# end of Command implementations
#----------------------------------------

	
#------------------------------------------------------------
# hash64_word_38(a0)
# Input : a0 = pointer to string (1 char per 32-bit word, low byte used)
# Output: a0 = hash in 0..63
# Clobbers: t0, t1
# Formula: h = (h * 38) XOR c
#------------------------------------------------------------
hash64_word_38:
    li    t0, 5384        # h = 5384 (seed)
0:
    lw    t1, 0(a0)       # load 32-bit word (char)
    beqz  t1, 1f          # if 0: end of string
    muli  t0, t0, 38      # h *= 38
    xor   t0, t0, t1      # h ^= c  (low byte only relevant)
	# li t2, 16777215
	# and  t0, t0, t2
    inc   a0              # next word (next char)
    j     0b
1:
    andi  a0, t0, 2047      # map to 0..20473
    ret


# fs_init(a0=fs_base, a1=block_size, a2=num_blocks)
fs_init:
    push ra
    # initialize super block
    li t0, 1128813396 # magic number 'CHST'
    sw t0, 0(a0)      # fs_base + 0: magic number
    li t0, 1
    sw t0, 1(a0)      # fs_base + 1: version, currently 
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
    # empty name
    sw zero, 1(t0) # name part 1
    sw zero, 2(t0) # name part 2
    # start block index: root dir is at block 1
    li t3, 1
    sw t3, 3(t0)   # start block index
    # size: undefined for directories, already initialized as 0

    # set parent directory index to self (1)
    sw t3, 250(t0)   # parent dir index
	# set link of next block to -1 (dirs never link)
	li t4, -1
	sw t4, 255(t0)

    # save start of superblock address in OS RAM
    sw a0, 1058(zero) # fs base address save


    # done, first 2 blocks are initialized, return
    pop ra
    ret



	
.data
	welcome: .asciz "FactOS 1.1.0\n"
	prompt: .asciz "> "
	cmd_hashes: .word 1083, 1228, 510, 834, 1679, 120, 1599, 1240, 193
	# "LS","MKDIR","TOUCH","CP","CPROM","RUN","RUNROM","MV","RM"
	unknown_cmd: .asciz "Error: Unknown Cmd"
	error_invalid_args: .asciz "Error: Invalid number of arguments"
	error_execution: .asciz "Error executing Cmd"
	rom_start_addresses: .word 50176, 58368
	dir_string: .asciz "DIR "

	