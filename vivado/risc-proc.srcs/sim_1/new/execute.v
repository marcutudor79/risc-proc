`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2024 12:07:12 AM
// Design Name: 
// Module Name: execute
// Project Name: 
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

module execute(
    input clk,
    input rst,
    
    // pipeline in/out
    input [`I_EXEC_SIZE-1:0] instruction_in,
    output reg [`I_EXEC_SIZE-1:0] instruction_out,
    
    // memory control
    output reg [`A_SIZE-1:0] addr,
    output reg [`D_SIZE-1:0] data_out,
    
    // read block fast result register
    output reg [`D_SIZE-1:0] result_exec
);

// regardless of the clock timing, fast forward the result
always @(*) begin
    result_exec = instruction_out[31:0];
end

always @(posedge clk) begin
    // Set the instruction that was used in the instruction_out register
    instruction_out[`I_EXEC_SIZE-1:64] <= instruction_in[`I_EXEC_SIZE-1:64];
    
    // Set the computed operand in the op0 place
    casex(instruction_in[`I_EXEC_OPCODE])
        `ADD:       instruction_out[31:0] <= instruction_in[63:32] + instruction_in[31:0];
        `ADDF:      instruction_out[31:0] <= instruction_in[63:32] + instruction_in[31:0];
        `SUB:       instruction_out[31:0] <= instruction_in[63:32] - instruction_in[31:0];
        `SUBF:      instruction_out[31:0] <= instruction_in[63:32] - instruction_in[31:0];
        `AND:       instruction_out[31:0] <= instruction_in[63:32] & instruction_in[31:0];
        `OR:        instruction_out[31:0] <= instruction_in[63:32] | instruction_in[31:0];
        `XOR:       instruction_out[31:0] <= instruction_in[63:32] ^ instruction_in[31:0];
        `NAND:      instruction_out[31:0] <= ~(instruction_in[63:32] & instruction_in[31:0]);
        `NOR:       instruction_out[31:0] <= ~(instruction_in[63:32] | instruction_in[31:0]);
        `NXOR:      instruction_out[31:0] <= ~(instruction_in[63:32] ^ instruction_in[31:0]);
        `SHIFTR:    instruction_out[31:0] <= instruction_in[`I_EXEC_DAT1]          >>  {instruction_in[`I_EXEC_OP1], instruction_in[`I_EXEC_OP2]};
        `SHIFTRA:   instruction_out[31:0] <= $signed(instruction_in[`I_EXEC_DAT1]) >>> {instruction_in[`I_EXEC_OP1], instruction_in[`I_EXEC_OP2]}; 
        `SHIFTL:    instruction_out[31:0] <= instruction_in[`I_EXEC_DAT1]          <<  {instruction_in[`I_EXEC_OP1], instruction_in[`I_EXEC_OP2]};
    endcase
end

endmodule
