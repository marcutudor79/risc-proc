`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2024 12:07:12 AM
// Design Name: 
// Module Name: execute
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
    casex(instruction[15:9])
        `NOP:       data_out = 0;
        `ADD:       operand_out <= instruction_in[`I_SIZE:`I_SIZE+`D_SIZE-1] + instruction_in[`I_SIZE:`I_SIZE+2*`D_SIZE-1];
        `ADDF:      operand_out <= [instruction[5:3]] + reg_block[instruction[2:0]];
        `SUB:       operand_out <= [instruction[5:3]] - reg_block[instruction[2:0]];
        `SUBF:      operand_out <= [instruction[5:3]] - reg_block[instruction[2:0]];
        `AND:       operand_out <= ock[instruction[5:3]] & reg_block[instruction[2:0]];
        `OR:        operand_out <= reg_block[instruction[5:3]] | reg_block[instruction[2:0]];
        `XOR:       operand_out <= reg_block[instruction[5:3]] ^ reg_block[instruction[2:0]];
        `NAND:      operand_out <= ~(reg_block[instruction[5:3]] & reg_block[instruction[2:0]]);
        `NOR:       operand_out <= ~(reg_block[instruction[5:3]] | reg_block[instruction[2:0]]);
        `NXOR:      operand_out <= ~(reg_block[instruction[5:3]] ^ reg_block[instruction[2:0]]);
        `SHIFTR:    operand_out <= reg_block[instruction[8:6]] >> instruction[5:0];
        `SHIFTRA:   operand_out <= $signed(reg_block[instruction[8:6]]) >>> instruction[5:0]; 
        `SHIFTL:    operand_out <= reg_block[instruction[8:6]] << instruction[5:0];
    endcase
end

endmodule
