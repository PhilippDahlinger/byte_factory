.text
.globl _start
# Line Comment
_start:	# Label Comment
	li s1, 1 # inline Comment
	li s2, 1
loop:
	add s1, s1, s2
	add s2, s1, s2
	j loop
	
.data
	Here
	Random stuff
	is there
