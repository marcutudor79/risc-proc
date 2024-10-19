//////////////////////////////////////////////////////////////////////////////////
// Company: -
// Engineer: Marculescu Tudor
//
// Create Date: 10/19/2024 12:35:41 PM
// Design Name: seq_core
// Module Name: seq_core
// Project Name: DSD project ACES
// Target Devices: -
// Tool Versions: vivado 2023.2
// Description: golden model of a seq_core
//
// Dependencies: https://users.dcae.pub.ro/~zhascsi/courses/dsd/golden_model.txt
//
// Revision: 1.0
// Revision 1.0 - File Created
// Additional Comments: -
//
//////////////////////////////////////////////////////////////////////////////////
/********** INCLUDE DEPENDENCIES **********/


/********** MACROS ***********************/
// ADDRESS BUS SIZE OF SEQ_CORE
`define A_SIZE (10)

// DATA BUS SIZE OF SEQ_CORE
`define D_SIZE (32)

// INSTRUCTION BUS SIZE OF SEQ_CORE
`define I_SIZE (16)

// OPCODE SIZE OF SEQ_CORE
`define C_SIZE (7)

// REGISTER DEFS
`define REG_BLOCK_SIZE (8)
`define REG_A_SIZE     (3)
`define R0             (3'd0)
`define R1             (3'd1)
`define R2             (3'd2)
`define R3             (3'd3)
`define R4             (3'd4)
`define R5             (3'd5)
`define R6             (3'd6)
`define R7             (3'd7)

`define READ_REGISTER  (1'd1)
`define WRITE_REGISTER (1'd0)

// OPCODE DEFS
`define NOP    (7'd0)
`define ADD    (7'd1)
`define ADDF   (7'd2)
`define SUB    (7'd3)
`define SUBF   (7'd4)
`define AND    (7'd5)
`define OR     (7'd6)
`define XOR    (7'd7)
`define NAND   (7'd8)
`define NOR    (7'd9)
`define NXOR   (7'd10)
`define SHIFTR (7'd11)
`define SHIFTL (7'd12)
