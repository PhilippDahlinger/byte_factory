.text
.globl _start
_start:
    # --- TEST 1: Forwarding in JAL ---
	li s1, 100 
    li s0, 50
    j jump1             # Should jump
    li s1, 123            # Should be skipped

jump1:
    li s2, 1              # Expected: s2 = 1

    # --- TEST 2: Forwarding in JALR (Indirect Jump) ---
    li s3, return_addr
    jalr zero, 0(s3)      # Jump indirectly
	li s4, 123

return_addr:
    li s4, 1              # Expected: s4 = 1

    # --- TEST 3: JAL with Offset ---
    j jump2
    li s5, 77             # Should be skipped
	li s6, 123

jump2:
    li s6, 1              # Expected: s6 = 1

    # --- TEST 4: JALR with Register Offset ---
    li s7, jump3
    jalr zero, 0(s7)      # Should jump to jump3

jump3:
    li s8, 1              # Expected: s8 = 1
	
	halt