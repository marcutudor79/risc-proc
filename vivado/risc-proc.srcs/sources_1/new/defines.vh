// PROC defines
`define DSIZE 32
`define ISIZE 16
`define CSIZE 4

// MEMORY defines
`define ASIZE   8
`define MEMSIZE (1<<`ASIZE)


// OPCODE defines
`define ADD 4'b0001
`define SUB 4'b0010

// ALU defines
`define operatie (`ISIZE-1:(`ISIZE-`CSIZE))
`define SIGN     (`DSIZE-1)

// REGS defines
`define R0 4'd0
`define R1 4'd1
`define R2 4'd2
`define R3 4'd3

`define addrmem ((`ISIZE-`CSIZE-1)):(`ISIZE-`CSIZE-`ASIZE))