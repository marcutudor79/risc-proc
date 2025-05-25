`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 01/08/2025 11:34:36 AM
// Design Name:
// Module Name: execute_floating_point
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
`include "seq_core.vh"

module execute_floating_point(
    input clk,
    input rst,

    // pipeline in/out
    input [`I_EXEC_SIZE-1:0] instruction_in,
    output reg [`I_EXEC_SIZE-1:0] instruction_out_exec_floating_3

);

// internal variable to save the result
reg [`I_EXEC_SIZE-1:0] instruction_out;
reg [`I_EXEC_SIZE-1:0] instruction_out_exec_floating_0;
reg [`I_EXEC_SIZE-1:0] instruction_out_exec_floating_1;
reg [`I_EXEC_SIZE-1:0] instruction_out_exec_floating_2;

/*  1. First compute the result based on the input instruction
*/
always @(*) begin

     // Set the instruction_in bits in the instruction_out region, (the operands value are computed after this)
     instruction_out[`I_EXEC_INSTR] = instruction_in[`I_EXEC_INSTR];

     casex(instruction_in[`I_EXEC_OPCODE])
        `ADDF:      instruction_out[`I_EXEC_DAT2] = instruction_in[`I_EXEC_DAT1] + instruction_in[`I_EXEC_DAT2];
        `SUBF:      instruction_out[`I_EXEC_DAT2] = instruction_in[`I_EXEC_DAT1] - instruction_in[`I_EXEC_DAT2];

        // default case is used when a NOP instruction is passed by READ stage
        default:    instruction_out = instruction_in;

     endcase
end

/* 2. Sample the instruction_out computed previously

*/
always @(posedge clk) begin
    instruction_out_exec_floating_0 <= instruction_out;
    instruction_out_exec_floating_1 <= instruction_out_exec_floating_0;
    instruction_out_exec_floating_2 <= instruction_out_exec_floating_1;
    instruction_out_exec_floating_3 <= instruction_out_exec_floating_2;
end

endmodule