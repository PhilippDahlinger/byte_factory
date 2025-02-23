[000] r1 = 5
[001] r13 = pc + 3
[002] push(r13)
[003] jump(5)
[004] exit(success)
[005] disp[1] = r1
[006] r1 = r1 - 1
[007] cmp(r1 , 0)
[008] jump(12, 6)
[009] r13 = pc + 3
[010] push(r13)
[011] jump(5)
[012] pc = pop()
