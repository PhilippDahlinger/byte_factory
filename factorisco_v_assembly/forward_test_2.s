.text
.globl _start

_start:
	li sp, 17407  # init stack

    # --- TEST 1: Forwarding from EX Stage ---
    li t0, 5           # t0 = 5
    addi t1, t0, 10    # t1 = t0 + 10 = 15 (EX forward)
    add  t2, t1, t0    # t2 = t1 + t0 = 15 + 5 = 20 (EX forward)
    # Expected: t0 = 5, t1 = 15, t2 = 20

    # --- TEST 2: Forwarding from MEM Stage ---
    li t3, 7           # t3 = 7
    addi t4, t3, 3     # t4 = t3 + 3 = 10
    lw t5, 0(sp)       # Dummy load to introduce MEM stage delay
    add t6, t4, t3     # t6 = t4 + t3 = 10 + 7 = 17 (MEM forward)
    # Expected: t3 = 7, t4 = 10, t6 = 17

    # --- TEST 3: Forwarding from WB Stage ---
    li s0, 9           # s0 = 9
    addi s1, s0, 2     # s1 = s0 + 2 = 11
    lw s2, 0(sp)       # Dummy load to delay WB stage
    add s3, s1, s0     # s3 = s1 + s0 = 11 + 9 = 20 (WB forward)
    # Expected: s0 = 9, s1 = 11, s3 = 20

    # --- TEST 4: Load-Use Forwarding (MEM hazard resolution) ---
    li s4, 100         # s4 = 100
    sw s4, 0(sp)       # Store s4 at memory location [sp]
    lw s5, 0(sp)       # Load s4 back into s5 (MEM -> EX hazard)
    add s6, s5, s4     # s6 = s5 + s4 = 100 + 100 = 200 (Load forwarding)
    # Expected: s4 = 100, s5 = 100, s6 = 200

    # --- TEST 5: Forwarding with Subtraction ---
    li a0, 50          # a0 = 50
    addi a1, a0, -20   # a1 = a0 - 20 = 30
    sub a2, a1, a0     # a2 = a1 - a0 = 30 - 50 = -20 (EX forward)
    # Expected: a0 = 50, a1 = 30, a2 = -20

    # --- TEST 6: Forwarding with Multiplication ---
    li a3, 4           # a3 = 4
    li a4, 6           # a4 = 6
    mul a5, a3, a4     # a5 = a3 * a4 = 4 * 6 = 24 (EX forward)
    add a6, a5, a3     # a6 = a5 + a3 = 24 + 4 = 28 (EX forward)
    # Expected: a3 = 4, a4 = 6, a5 = 24, a6 = 28

    # --- END: Halt execution ---
    nop
	nop
	nop
	nop
    halt
	nop
	nop
	nop
	nop
	nop
	