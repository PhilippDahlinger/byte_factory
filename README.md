# Byte Factory 2.0 - Powered by Bython
This repository contains the code for the Bython compiler to create programs 
for the Byte Factory 2.0 CPU. It converts Bython scripts into assembler code (*.bas), and then into a blueprint string which can be loaded in Factorio.
## Specs of the CPU:
- 12 Tick Clock cycle = 5Hz on normal game speed
- Separate Program and Data ROM
- 13 general purpose registers
- RAM with over 2000 addresses
- Hardware Stack
- User Input with and without Interrupts
- Display Registers

## Instruction Overview
The instruction is made up by the OpCode `(C)`, three register addresses `(0)`, `(1)`, and `(2)`,  and an optional Immediate value `(I)`.
Generally, Address `(0)` is the write back register, `(1)` and `(2)` are the operands.
An example instruction is
```u
(C)=2, (0)=2, (1)=1, (2)=14, (I)=23
```
`(C)` = 2 is an add instruction. This instruction will load the value of register 1, and adds it together with
the immediate value `(I)=23`, since `(2)=14` is the code to load the immediate. The result will be saved in register `(0) = 2`.
In Bython, this would be the line
```
r2 = r1 + 23
```
## The Bython language
While each line is very similar to assembly, it implements higher control structures like `if`, `else`, `while` and function calls.
The syntax is python-like, using indents and other python syntax. However, every line (usually) translates to one instruction.

## Advent of Code 2024
To test the CPU and the Bython compiler, I tried to solve as many daily challenges of the Advent of Code 2024. The Bython solutions 
are given in `bython_scripts/aoc_2024`. 

Since we have to also load the puzzle input into the Data ROM of the CPU, I used a Python script which encodes the puzzle input and creates a blueprint out of it.
dwwWhile in theory, one could encode every character of the text file individually, the decoding process takes a while on the Byte Factory CPU.
To speed-up the process and to have more fun, I encoded the puzzle files differently, depending on the problem setting. 



