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
    
    // input signals
    input [`REG_A_SIZE-1:0] sel_op1,
    input [`REG_A_SIZE-1:0] sel_op2,
    
    // pipeline in/out
    input [`I_SIZE+`D_SIZE*2-1:0] instruction_in,
    output reg [`D_SIZE-1:0] operand_out,
    
    // memory control
    output reg [`A_SIZE-1:0] addr,
    output reg [`D_SIZE-1:0] data_out
);

always @(posedge clk) begin
    casex(instruction_in[79:73])
        `NOP:       data_out    <= 0;
        `ADD:       operand_out <= instruction_in[63:32] + instruction_in[31:0];
        `ADDF:      operand_out <= instruction_in[63:32] + instruction_in[31:0];
        `SUB:       operand_out <= instruction_in[63:32] - instruction_in[31:0];
        `SUBF:      operand_out <= instruction_in[63:32]- instruction_in[31:0];
        `AND:       operand_out <= instruction_in[63:32] & instruction_in[31:0];
        `OR:        operand_out <= instruction_in[63:32] | instruction_in[31:0];
        `XOR:       operand_out <= instruction_in[63:32] ^ instruction_in[31:0];
        `NAND:      operand_out <= ~(instruction_in[63:32] & instruction_in[31:0]);
        `NOR:       operand_out <= ~(instruction_in[63:32] | instruction_in[31:0]);
        `NXOR:      operand_out <= ~(instruction_in[63:32] ^ instruction_in[31:0]);
        `SHIFTR:    operand_out <= instruction_in[72:70] >> instruction_in[69:64];
        `SHIFTRA:   operand_out <= $signed(instruction_in[72:70]) >>> instruction_in[69:64]; 
        `SHIFTL:    operand_out <= instruction_in[8:6] << instruction_in[5:0];
    endcase
end

endmodule
