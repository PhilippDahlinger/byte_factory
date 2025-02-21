.text
.globl _start

_start:
    # --- TEST 1: Forwarding into Branch Condition (BEQ) ---
	li a2, 100
    li a0, 42
    li a1, 42
    beq a0, a1, branch1   # Should branch
    li a2, 99             # Should be skipped

branch1:
    li a3, 1              # Expected: a3 = 1

    # --- TEST 2: Forwarding in Branch Condition (BNE) ---
	li a6, 100
    li a4, 15
    li a5, 20
    bne a4, a5, branch2   # Should branch
    li a6, 77             # Should be skipped

branch2:
    li a7, 1              # Expected: a7 = 1

    # --- TEST 3: Forwarding in BGE/BGEU (Greater or Equal) ---
	li t2, 100
    li t0, -10
    li t1, -10
    bge t0, t1, branch3   # Should branch
    li t2, 55             # Should be skipped

branch3:
    li t3, 1              # Expected: t3 = 1

    # --- TEST 4: Forwarding in BLT/BLTU (Less Than) ---
	li s2, 100
    li s0, 5
    li s1, 10
    blt s0, s1, branch4   # Should branch
    li s2, 88             # Should be skipped

branch4:
    li s3, 1              # Expected: s3 = 1

    # --- TEST 5: Forwarding in BLEZ/BGEZ (Signed Comparisons) ---
	li s5, 100
    li s4, -1
    ble s4, zero, branch5      # Should branch
    li s5, 99             # Should be skipped

branch5:
    li s6, 1              # Expected: s6 = 1

    # --- END: Halt execution ---
    halt
	nop
	nop
	nop
	nop
	nop
	