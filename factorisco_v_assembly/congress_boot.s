.text
.globl _start
_start:
    # enable interrupts
	li t0, 1
	sw t0, 18(zero)

    li sp, 17400  # init sp
    # cls
    li a7, 15
    ecall
    li a0, 0
	li a1, 0
	li a7, 6
	ecall # set cursor to 0,0
	li a0, 0
	li a7, 11
	ecall #set fdr to 0
    # print boot messages
    la a0, str_boot
    li a7, 17
    ecall
    la a0, str_online
    li a7, 17
    ecall
    la a0, str_welcome
    li a7, 17
    ecall
    1:
    li a0, 1
    j 1b

.data
	str_boot: .asciz "Rebooting... "
	str_online: .asciz "FactOS online."
	str_welcome: .asciz "Welcome to the 39c3!"