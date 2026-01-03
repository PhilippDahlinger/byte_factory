.text

li a7, 17
la a0, str_title_1
ecall

li a7, 17
la a0, str_title_2
ecall

li a7, 16
la a0, str_title_3
ecall

li a7, 17
la a0, str_title_4
ecall

li a7, 33
ecall

li a7, 17
la a0, str_title_5
ecall

li a7, 1
ecall


.data
str_title_1: .asciz "Building a CPU in"
str_title_2: .asciz "Factorio:"
str_title_3: .asciz "From D-Flip-Flops to"
str_title_4: .asciz "an Operating System"
str_title_5: .asciz "          by Philipp"