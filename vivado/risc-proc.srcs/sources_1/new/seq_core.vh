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
`define OUT_OF_BOUND_REG (3'd8)

`define READ_REGISTER  (1'd1)
`define WRITE_REGISTER (1'd0)

// OPCODE DEFS
`define NOP         (7'b0000000)
`define ADD         (7'b0000001)
`define ADDF        (7'b0000010)
`define SUB         (7'b0000011)
`define SUBF        (7'b0000100)
`define AND         (7'b0000101)
`define OR          (7'b0000110)
`define XOR         (7'b0000111)
`define NAND        (7'b0001000)
`define NOR         (7'b0001001)
`define NXOR        (7'b0001010)
`define SHIFTR      (7'b0001011)
`define SHIFTRA     (7'b0001100)
`define SHIFTL      (7'b0001101)
`define LOAD        (7'b00111xx)
`define LOADC       (7'b01000xx)
`define STORE       (7'b01001xx)
`define JMP         (7'b0101xxx)
`define JMPR        (7'b0110xxx)
`define JMPcond     (7'b0111xxx)
`define JMPN        (7'b0111000)
`define JMPNN       (7'b0111001)
`define JMPZ        (7'b0111010)
`define JMPNZ       (7'b0111011)
`define JMPRcond    (7'b1000xxx)
`define JMPRN       (7'b1000000)
`define JMPRNN      (7'b1000001)
`define JMPRZ       (7'b1000010)
`define JMPRNZ      (7'b1000011)
`define HALT        (7'b1111111)

// COND defs for JMP op
`define N           (3'b000)  // negative
`define NN          (3'b001)  // not negative
`define Z           (3'b010)  // zero  
`define NZ          (3'b011)  // not zero

// MEM defs
`define READ_ACTIVE     (1'b1)
`define READ_DISABLED   (1'b0)
`define WRITE_ACTIVE    (1'b1)
`define WRITE_DISABLED  (1'b0)

// PIPELINE SPECIFIC

// READ STAGE
`define I_OPCODE (`I_SIZE-1):(`I_SIZE-`C_SIZE)
`define I_OP0    8:6
`define I_OP1    5:3
`define I_OP2    2:0

// EXEC STAGE
// I_EXEC_SIZE = { I_SIZE, D_SIZE (DAT1), D_SIZE (DAT2)}
`define I_EXEC_SIZE   (`I_SIZE + (2*`D_SIZE))

// INSTRUCTION SECTION 16 bits
`define I_EXEC_INSTR  (`I_EXEC_SIZE-1):(`D_SIZE*2)
`define I_EXEC_OPCODE (`I_EXEC_SIZE-1):(`I_EXEC_SIZE-`C_SIZE)
`define I_EXEC_OP0    (`I_EXEC_SIZE-1-`C_SIZE):(`I_EXEC_SIZE-`C_SIZE-`REG_A_SIZE)
`define I_EXEC_OP1    (`I_EXEC_SIZE-`C_SIZE-`REG_A_SIZE-1):(`I_EXEC_SIZE-`C_SIZE-(2*`REG_A_SIZE))
`define I_EXEC_OP2    (`I_EXEC_SIZE-`C_SIZE-(2*`REG_A_SIZE)-1):(`I_EXEC_SIZE-`C_SIZE-(3*`REG_A_SIZE))
`define I_EXEC_OFFSET ((`D_SIZE*2)+5):(`D_SIZE*2)
`define I_EXEC_COND   (`I_EXEC_SIZE-5):(`I_EXEC_SIZE-7)
`define I_EXEC_CONST  ((`D_SIZE*2)+7):(`D_SIZE*2)
`define I_EXEC_LOAD_DEST (`I_EXEC_SIZE-1-5):(`I_EXEC_SIZE-5-`REG_A_SIZE)

//  DATA SECTION 64 bits
`define I_EXEC_DAT2   `D_SIZE-1:0
`define I_EXEC_DAT1   (2*`D_SIZE)-1:`D_SIZE

// DATA DEPENDENCY STAGE
`define OP_SEL_SIZE        (3)
`define DEP_SEL_SIZE       (2)

// OVERRIDE ONE OF THE OPERANDS WITH THE RESULT OF EXEC STAGE
`define OVERRIDE_EXEC_DAT0 (3'd0)
`define OVERRIDE_EXEC_DAT1 (3'd1)
`define OVERRIDE_EXEC_DAT2 (3'd2)

// OVERRIDE ONE OF THE OPERANDS WITH THE MEM RETRIEVAL 
`define OVERRIDE_MEM_DAT1 (3'd3)
`define OVERRIDE_MEM_DAT2 (3'd4)

// OVERRIDE ONE OF THE OPERANDS WITH THE LOADC RESULT OF EXEC STAGE
`define OVERRIDE_CONSTANT_DAT1 (3'd5)
`define OVERRIDE_CONSTANT_DAT2 (3'd6)