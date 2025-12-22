.text
init:
	li s1, 1 # prev. fib number
	li s2, 1 # current fib number
	li s3, 0 # loop counter
	li s4, 10 # number of iterations
loop:
	beq s3, s4, end_loop # for loop implementation
	# compute next fibonacci number
	add t1, s1, s2
	mv s1, s2
	mv s2, t1
	# print current number
	mv a0, s2
	li a7, 19
	ecall # print_int
	# new line
	li a7, 33
	ecall # new line
	
	# increment loop counter
	addi s3, s3, 1
	j loop
end_loop:

# end program
li a7, 1
ecall # exit

.data